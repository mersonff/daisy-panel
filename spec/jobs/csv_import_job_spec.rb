require 'rails_helper'

RSpec.describe CsvImportJob, type: :job do
  let(:user) { create(:user) }
  let(:import_report) { create(:import_report, user: user) }

  describe '#perform' do
    context 'with valid CSV content' do
      let(:cpf1) { CPF.generate }
      let(:cpf2) { CPF.generate }
      let(:csv_content) do
        <<~CSV
          nome,cpf,telefone,endereco,cidade,estado,cep
          João Silva,#{cpf1},11999999999,Rua das Flores 123,São Paulo,SP,01234-567
          Maria Santos,#{cpf2},21888888888,Av Principal 456,Rio de Janeiro,RJ,20000-000
        CSV
      end

      it 'processes CSV and creates clients successfully' do
        expect {
          described_class.perform_now(import_report.id, csv_content)
        }.to change(Client, :count).by(2)

        import_report.reload
        expect(import_report.status).to eq('completed')
        expect(import_report.success_count).to eq(2)
        expect(import_report.error_count).to eq(0)
        expect(import_report.total_lines).to eq(2)
      end

      it 'updates import report timestamps' do
        described_class.perform_now(import_report.id, csv_content)

        import_report.reload
        expect(import_report.started_at).to be_present
        expect(import_report.completed_at).to be_present
      end

      it 'broadcasts completion notification' do
        expect(ActionCable.server).to receive(:broadcast).with(
          "import_notifications_#{user.id}",
          hash_including(
            type: "import_completed",
            import_report_id: import_report.id,
            success_count: 2,
            error_count: 0
          )
        )

        described_class.perform_now(import_report.id, csv_content)
      end
    end

    context 'with invalid CSV content' do
      let(:csv_content) do
        <<~CSV
          nome,cpf,telefone,endereco,cidade,estado,cep
          ,11144477735,11999999999,Rua das Flores 123,São Paulo,SP,01234-567
          Maria Santos,123,21888888888,Av Principal 456,Rio de Janeiro,RJ,20000-000
        CSV
      end

      it 'handles validation errors' do
        described_class.perform_now(import_report.id, csv_content)

        import_report.reload
        expect(import_report.status).to eq('completed')
        expect(import_report.success_count).to eq(0)
        expect(import_report.error_count).to eq(2)
        expect(import_report.error_details).to be_present
      end

      it 'stores detailed error information' do
        described_class.perform_now(import_report.id, csv_content)

        import_report.reload
        error_details = import_report.error_details

        expect(error_details).to be_an(Array)
        expect(error_details.first).to include('line', 'errors')
        expect(error_details.first['line']).to eq(2)
      end
    end

    context 'with mixed valid and invalid data' do
      let(:cpf3) { CPF.generate }
      let(:cpf4) { CPF.generate }
      let(:csv_content) do
        <<~CSV
          nome,cpf,telefone,endereco,cidade,estado,cep
          João Silva,#{cpf3},11999999999,Rua das Flores 123,São Paulo,SP,01234-567
          ,invalid_cpf,21888888888,Av Principal 456,Rio de Janeiro,RJ,20000-000
          Pedro Costa,#{cpf4},31777777777,Rua Central 789,Belo Horizonte,MG,30000-000
        CSV
      end

      it 'processes valid entries and reports errors for invalid ones' do
        expect {
          described_class.perform_now(import_report.id, csv_content)
        }.to change(Client, :count).by(2)

        import_report.reload
        expect(import_report.status).to eq('completed')
        expect(import_report.success_count).to eq(2)
        expect(import_report.error_count).to eq(1)
        expect(import_report.total_lines).to eq(3)
      end
    end

    context 'when job fails completely' do
      let(:csv_content) { "invalid,csv,format" }

      before do
        allow(CSV).to receive(:parse).and_raise(StandardError.new("CSV parsing error"))
      end

      it 'marks import as failed and broadcasts error' do
        expect(ActionCable.server).to receive(:broadcast).with(
          "import_notifications_#{user.id}",
          hash_including(
            type: "import_failed",
            import_report_id: import_report.id
          )
        )

        described_class.perform_now(import_report.id, csv_content)

        import_report.reload
        expect(import_report.status).to eq('failed')
        expect(import_report.error_details).to be_present
      end
    end

    context 'when processing exception occurs' do
      let(:csv_content) do
        <<~CSV
          nome,cpf,telefone,endereco,cidade,estado,cep
          João Silva,12345678901,11999999999,Rua das Flores 123,São Paulo,SP,01234-567
        CSV
      end

      before do
        allow_any_instance_of(described_class).to receive(:extract_client_data).and_raise(RuntimeError.new("Processing error"))
      end

      it 'captures processing errors in error details' do
        described_class.perform_now(import_report.id, csv_content)

        import_report.reload
        expect(import_report.status).to eq('completed')
        expect(import_report.error_count).to eq(1)
        expect(import_report.error_details.first['errors']).to include("Erro de processamento: Processing error")
      end
    end

    describe '#extract_client_data' do
      let(:job) { described_class.new }

      context 'with standard headers' do
        let(:row) do
          {
            nome: 'João Silva',
            cpf: '123.456.789-01',
            telefone: '(11) 99999-9999',
            endereco: 'Rua das Flores, 123',
            cidade: 'São Paulo',
            estado: 'São Paulo',
            cep: '01234567'
          }
        end

        it 'extracts client data correctly' do
          data = job.send(:extract_client_data, row)

          expect(data[:name]).to eq('João Silva')
          expect(data[:cpf]).to eq('12345678901')
          expect(data[:phone]).to eq('(11) 99999-9999')
          expect(data[:address]).to eq('Rua das Flores, 123')
          expect(data[:city]).to eq('São Paulo')
          expect(data[:state]).to eq('SP')
          expect(data[:cep]).to eq('01234-567')
        end
      end

      context 'with alternative headers' do
        let(:row) do
          {
            name: 'Maria Santos',
            phone: '21888888888',
            address: 'Av Principal 456',
            city: 'Rio de Janeiro',
            state: 'RJ',
            zipcode: '20000000'
          }
        end

        it 'maps alternative headers correctly' do
          data = job.send(:extract_client_data, row)

          expect(data[:name]).to eq('Maria Santos')
          expect(data[:phone]).to eq('21888888888')
          expect(data[:address]).to eq('Av Principal 456')
          expect(data[:city]).to eq('Rio de Janeiro')
          expect(data[:state]).to eq('RJ')
          expect(data[:cep]).to eq('20000-000')
        end
      end

      context 'with short address' do
        let(:row) do
          {
            nome: 'Pedro Costa',
            endereco: 's/n'
          }
        end

        it 'complements short addresses' do
          data = job.send(:extract_client_data, row)
          expect(data[:address]).to eq('s/n')
        end
      end

      context 'with blank values' do
        let(:row) do
          {
            nome: '',
            cpf: nil,
            telefone: '   '
          }
        end

        it 'skips blank values' do
          data = job.send(:extract_client_data, row)
          expect(data).to be_empty
        end
      end

      context 'with incomplete CEP' do
        let(:row) do
          {
            nome: 'Test',
            cep: '12345'
          }
        end

        it 'returns the value and validation error' do
          data = job.send(:extract_client_data, row)
          expect(data[:cep]).to eq('12345')
        end
      end
    end

    describe '#convert_state_name_to_acronym' do
      let(:job) { described_class.new }

      it 'converts state names to acronyms' do
        expect(job.send(:convert_state_name_to_acronym, 'São Paulo')).to eq('SP')
        expect(job.send(:convert_state_name_to_acronym, 'Rio de Janeiro')).to eq('RJ')
        expect(job.send(:convert_state_name_to_acronym, 'Minas Gerais')).to eq('MG')
      end

      it 'handles states without accents' do
        expect(job.send(:convert_state_name_to_acronym, 'Sao Paulo')).to eq('SP')
        expect(job.send(:convert_state_name_to_acronym, 'Ceara')).to eq('CE')
      end

      it 'returns acronym if already provided' do
        expect(job.send(:convert_state_name_to_acronym, 'SP')).to eq('SP')
        expect(job.send(:convert_state_name_to_acronym, 'RJ')).to eq('RJ')
      end

      it 'handles unknown states' do
        expect(job.send(:convert_state_name_to_acronym, 'Unknown State')).to eq('UNKNOWN STATE')
      end
    end

    describe '#build_completion_message' do
      let(:job) { described_class.new }

      it 'builds message for successful import without errors' do
        message = job.send(:build_completion_message, 5, 0)
        expect(message).to eq('5 clientes importados com sucesso!')
      end

      it 'builds message for mixed success and errors' do
        message = job.send(:build_completion_message, 3, 2)
        expect(message).to eq('3 clientes importados com sucesso. 2 linhas com erro.')
      end

      it 'builds message for import with only errors' do
        message = job.send(:build_completion_message, 0, 5)
        expect(message).to eq('Nenhum cliente foi importado. 5 linhas com erro.')
      end
    end
  end
end

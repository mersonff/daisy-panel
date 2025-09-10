require 'rails_helper'

RSpec.describe CsvImportService do
  let(:user) { create(:user) }
  let(:csv_content) { "nome,cpf\nJoão Silva,12345678901" }
  let(:csv_file) do
    instance_double(ActionDispatch::Http::UploadedFile,
      blank?: false,
      content_type: "text/csv",
      original_filename: "test.csv",
      read: csv_content
    )
  end

  subject { described_class.new(user, csv_file) }

  describe '#call' do
    context 'with valid file' do
      before do
        allow(CsvImportJob).to receive(:perform_later)
      end

      it 'creates import report and schedules job' do
        expect {
          subject.call
        }.to change(ImportReport, :count).by(1)

        import_report = ImportReport.last
        expect(import_report.user).to eq(user)
        expect(import_report.filename).to eq("test.csv")
        expect(import_report.status).to eq("pending")
      end

      it 'schedules csv import job' do
        subject.call

        expect(CsvImportJob).to have_received(:perform_later)
          .with(ImportReport.last.id, csv_content)
      end

      it 'returns success response' do
        result = subject.call

        expect(result).to include(
          message: "Importação iniciada! Você será notificado quando concluída.",
          import_report_id: ImportReport.last.id,
          status: "processing"
        )
      end
    end

    context 'with no file' do
      let(:csv_file) { nil }

      it 'returns validation error' do
        result = subject.call

        expect(result).to eq({
          error: "Nenhum arquivo foi enviado",
          status: :unprocessable_content
        })
      end
    end

    context 'with blank file' do
      let(:csv_file) do
        instance_double(ActionDispatch::Http::UploadedFile, blank?: true)
      end

      it 'returns validation error' do
        result = subject.call

        expect(result).to eq({
          error: "Nenhum arquivo foi enviado",
          status: :unprocessable_content
        })
      end
    end

    context 'with invalid file type' do
      let(:csv_file) do
        instance_double(ActionDispatch::Http::UploadedFile,
          blank?: false,
          content_type: "text/plain",
          original_filename: "test.txt"
        )
      end

      it 'returns validation error' do
        result = subject.call

        expect(result).to eq({
          error: "Por favor, envie um arquivo CSV válido",
          status: :unprocessable_content
        })
      end
    end

    context 'with empty file content' do
      let(:csv_file) do
        instance_double(ActionDispatch::Http::UploadedFile,
          blank?: false,
          content_type: "text/csv",
          original_filename: "test.csv",
          read: ""
        )
      end

      it 'returns validation error' do
        result = subject.call

        expect(result).to eq({
          error: "O arquivo CSV está vazio",
          status: :unprocessable_content
        })
      end
    end

    context 'when unexpected error occurs' do
      before do
        allow(csv_file).to receive(:read).and_raise(StandardError.new("Unexpected error"))
      end

      it 'returns internal server error' do
        result = subject.call

        expect(result).to eq({
          error: "Erro interno do servidor",
          status: :internal_server_error
        })
      end

      it 'logs the error' do
        allow(Rails.logger).to receive(:error)

        subject.call

        expect(Rails.logger).to have_received(:error).with("Erro na importação CSV: Unexpected error")
      end
    end
  end

  describe '#valid_csv_file?' do
    context 'with csv content type' do
      it 'returns true' do
        expect(subject.send(:valid_csv_file?)).to be true
      end
    end

    context 'with csv file extension' do
      let(:csv_file) do
        instance_double(ActionDispatch::Http::UploadedFile,
          content_type: "application/octet-stream",
          original_filename: "test.csv"
        )
      end

      it 'returns true' do
        expect(subject.send(:valid_csv_file?)).to be true
      end
    end

    context 'with invalid type and extension' do
      let(:csv_file) do
        instance_double(ActionDispatch::Http::UploadedFile,
          content_type: "text/plain",
          original_filename: "test.txt"
        )
      end

      it 'returns false' do
        expect(subject.send(:valid_csv_file?)).to be false
      end
    end
  end

  describe '#count_data_lines' do
    it 'counts lines excluding header' do
      content = "header\nline1\nline2\nline3"
      expect(subject.send(:count_data_lines, content)).to eq(3)
    end

    it 'ignores blank lines' do
      content = "header\nline1\n\nline2\n"
      expect(subject.send(:count_data_lines, content)).to eq(2)
    end

    it 'returns 0 for header only' do
      content = "header"
      expect(subject.send(:count_data_lines, content)).to eq(0)
    end

    it 'returns 0 for empty content' do
      content = ""
      expect(subject.send(:count_data_lines, content)).to eq(0)
    end
  end
end

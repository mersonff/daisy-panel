require "csv"

class CsvImportJob < ApplicationJob
  queue_as :default

  def perform(import_report_id, csv_content)
    import_report = ImportReport.find(import_report_id)

    import_report.update!(
      status: "processing",
      started_at: Time.current
    )

    begin
      created_count = 0
      errors_count = 0
      detailed_errors = []

      # Parse CSV content
      csv_data = CSV.parse(csv_content, headers: true, header_converters: :symbol)

      csv_data.each_with_index do |row, index|
        line_number = index + 2 # +2 porque é linha 2 no arquivo (após header)

        begin
          # Extrair dados da linha
          client_data = extract_client_data(row)

          # Criar cliente
          client = import_report.user.clients.build(client_data)

          if client.save
            created_count += 1
          else
            errors_count += 1
            detailed_errors << {
              line: line_number,
              name: client_data[:name] || "Linha #{line_number}",
              cpf: client_data[:cpf],
              errors: client.errors.full_messages
            }
          end
        rescue => e
          errors_count += 1
          detailed_errors << {
            line: line_number,
            name: "Linha #{line_number}",
            cpf: nil,
            errors: [ "Erro de processamento: #{e.message}" ]
          }
        end
      end

      import_report.update!(
        status: "completed",
        success_count: created_count,
        error_count: errors_count,
        total_lines: csv_data.length,
        error_details: detailed_errors,
        completed_at: Time.current
      )

      # Broadcast via ActionCable
      Rails.logger.info "Broadcasting import completion for user #{import_report.user_id}"
      broadcast_data = {
        type: "import_completed",
        import_report_id: import_report.id,
        success_count: created_count,
        error_count: errors_count,
        message: build_completion_message(created_count, errors_count)
      }
      Rails.logger.info "Broadcast data: #{broadcast_data.inspect}"

      ActionCable.server.broadcast(
        "import_notifications_#{import_report.user_id}",
        broadcast_data
      )
      Rails.logger.info "Broadcast sent successfully"

    rescue => e
      Rails.logger.error "Erro na importação CSV: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      import_report.update!(
        status: "failed",
        error_details: [ { error: "Erro interno: #{e.message}" } ],
        completed_at: Time.current
      )

      # Broadcast error
      ActionCable.server.broadcast(
        "import_notifications_#{import_report.user_id}",
        {
          type: "import_failed",
          import_report_id: import_report.id,
          message: "Erro durante a importação. Tente novamente."
        }
      )
    end
  end

  private

  def extract_client_data(row)
    # Detectar automaticamente as colunas baseado nos headers
    data = {}

    # Mapear campos automaticamente
    row.each do |key, value|
      next if value.blank?

      key_str = key.to_s.downcase
      value = value.to_s.strip

      case key_str
      when /nome|name/
        data[:name] = value
      when /cpf/
        cpf_clean = value.gsub(/\D/, "") # Remove formatação
        # Garantir que CPF tenha 11 dígitos
        data[:cpf] = cpf_clean.length == 11 ? cpf_clean : nil
      when /telefone|phone|fone/
        data[:phone] = value
      when /endereo|endereço|endereco|address/
        # Tratar endereços muito curtos
        address_value = value.strip
        if address_value.length < 5
          # Se o endereço é muito curto (como "s/n"), complementar
          data[:address] = "#{address_value}, número não informado"
        else
          data[:address] = address_value
        end
      when /cidade|city/
        data[:city] = value
      when /estado|state|uf/
        data[:state] = convert_state_name_to_acronym(value)
      when /cep|zipcode/
        cep_clean = value.gsub(/\D/, "") # Remove formatação
        # Formatar CEP para o padrão esperado
        if cep_clean.length == 8
          data[:cep] = "#{cep_clean[0..4]}-#{cep_clean[5..7]}"
        elsif cep_clean.length == 5
          # CEP incompleto, tentar complementar
          data[:cep] = "#{cep_clean}-000"
        else
          data[:cep] = nil
        end
      end
    end

    data
  end

  def convert_state_name_to_acronym(state_name)
    return state_name if state_name.length <= 2 # Já é sigla

    mapping = {
      "acre" => "AC",
      "alagoas" => "AL",
      "amapá" => "AP",
      "amapa" => "AP",
      "amazonas" => "AM",
      "bahia" => "BA",
      "ceará" => "CE",
      "ceara" => "CE",
      "distrito federal" => "DF",
      "espírito santo" => "ES",
      "espirito santo" => "ES",
      "goiás" => "GO",
      "goias" => "GO",
      "maranhão" => "MA",
      "maranhao" => "MA",
      "mato grosso" => "MT",
      "mato grosso do sul" => "MS",
      "minas gerais" => "MG",
      "pará" => "PA",
      "para" => "PA",
      "paraíba" => "PB",
      "paraiba" => "PB",
      "paraná" => "PR",
      "parana" => "PR",
      "pernambuco" => "PE",
      "piauí" => "PI",
      "piaui" => "PI",
      "rio de janeiro" => "RJ",
      "rio grande do norte" => "RN",
      "rio grande do sul" => "RS",
      "rondônia" => "RO",
      "rondonia" => "RO",
      "roraima" => "RR",
      "santa catarina" => "SC",
      "são paulo" => "SP",
      "sao paulo" => "SP",
      "sergipe" => "SE",
      "tocantins" => "TO"
    }

    mapping[state_name.downcase] || state_name.upcase
  end

  def build_completion_message(success_count, error_count)
    if error_count == 0
      "#{success_count} clientes importados com sucesso!"
    elsif success_count > 0
      "#{success_count} clientes importados com sucesso. #{error_count} linhas com erro."
    else
      "Nenhum cliente foi importado. #{error_count} linhas com erro."
    end
  end
end

class CsvImportService
  class ValidationError < StandardError; end

  def initialize(user, csv_file)
    @user = user
    @csv_file = csv_file
  end

  def call
    validate_file!
    csv_content = read_file_content
    total_lines = count_data_lines(csv_content)

    import_report = create_import_report(total_lines)
    schedule_import_job(import_report, csv_content)

    build_success_response(import_report, total_lines)
  rescue ValidationError => e
    build_error_response(e.message, :unprocessable_content)
  rescue => e
    Rails.logger.error "Erro na importação CSV: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    build_error_response("Erro interno do servidor", :internal_server_error)
  end

  private

  attr_reader :user, :csv_file

  def validate_file!
    raise ValidationError, "Nenhum arquivo foi enviado" if csv_file.blank?

    unless valid_csv_file?
      raise ValidationError, "Por favor, envie um arquivo CSV válido"
    end
  end

  def valid_csv_file?
    csv_file.content_type == "text/csv" ||
      csv_file.original_filename&.ends_with?(".csv")
  end

  def read_file_content
    content = csv_file.read.force_encoding("UTF-8")
    raise ValidationError, "O arquivo CSV está vazio" if content.blank?
    content
  end

  def count_data_lines(csv_content)
    lines = csv_content.split("\n").reject(&:blank?)
    [ lines.length - 1, 0 ].max # Subtrair header, mínimo 0
  end

  def create_import_report(total_lines)
    user.import_reports.create!(
      filename: csv_file.original_filename,
      status: "pending",
      total_lines: total_lines
    )
  end

  def schedule_import_job(import_report, csv_content)
    CsvImportJob.perform_later(import_report.id, csv_content)
  end

  def build_success_response(import_report, total_lines)
    {
      message: "Importação iniciada! Você será notificado quando concluída.",
      import_report_id: import_report.id,
      status: "processing",
      total_lines: total_lines
    }
  end

  def build_error_response(message, status)
    { error: message, status: status }
  end
end

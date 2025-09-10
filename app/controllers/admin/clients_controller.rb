class Admin::ClientsController < Admin::DashboardController
  before_action :authenticate_user!
  before_action :set_client, only: %i[show edit update destroy]

  def index
    clients_scope = ClientsQuery.new(current_user.clients).call(params)
    @pagy, @clients = pagy(clients_scope)
  end

  def show
  end

  def new
    @client = current_user.clients.build
  end

  def create
    @client = current_user.clients.build(client_params)

    if @client.save
      redirect_to admin_client_path(@client), notice: "Cliente foi criado com sucesso."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @client.update(client_params)
      redirect_to admin_client_path(@client), notice: "Cliente foi atualizado com sucesso."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @client.destroy!
    redirect_to admin_clients_path, notice: "Cliente foi removido com sucesso."
  end

  def import_csv
    begin
      csv_file = params[:csv_file]

      if csv_file.blank?
        render json: { error: "Nenhum arquivo foi enviado" }, status: :unprocessable_content
        return
      end

      # Validar se é um arquivo CSV
      unless csv_file.content_type == "text/csv" || csv_file.original_filename.ends_with?(".csv")
        render json: { error: "Por favor, envie um arquivo CSV válido" }, status: :unprocessable_content
        return
      end

      # Ler conteúdo do arquivo
      csv_content = csv_file.read.force_encoding("UTF-8")

      # Validar se o arquivo não está vazio
      if csv_content.blank?
        render json: { error: "O arquivo CSV está vazio" }, status: :unprocessable_content
        return
      end

      # Contar linhas para o relatório
      lines = csv_content.split("\n").reject(&:blank?)
      total_lines = [ lines.length - 1, 0 ].max # Subtrair header, mínimo 0

      # Criar relatório de importação
      import_report = current_user.import_reports.create!(
        filename: csv_file.original_filename,
        status: "pending",
        total_lines: total_lines
      )

      # Agendar job assíncrono com o conteúdo do arquivo
      CsvImportJob.perform_later(import_report.id, csv_content)

      render json: {
        message: "Importação iniciada! Você será notificado quando concluída.",
        import_report_id: import_report.id,
        status: "processing",
        total_lines: total_lines
      }

    rescue => e
      Rails.logger.error "Erro na importação CSV: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: "Erro interno do servidor" }, status: :internal_server_error
    end
  end

  private

  def set_client
    @client = current_user.clients.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :address, :city, :state, :cep, :phone, :cpf)
  end
end

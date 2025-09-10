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
    result = CsvImportService.new(current_user, params[:csv_file]).call

    if result[:error]
      render json: { error: result[:error] }, status: result[:status]
    else
      render json: result
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

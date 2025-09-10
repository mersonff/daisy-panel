class Admin::ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: %i[show edit update destroy]
  layout "admin"

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

  private

  def set_client
    @client = current_user.clients.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :address, :city, :state, :cep, :phone, :cpf)
  end
end

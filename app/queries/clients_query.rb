class ClientsQuery
  def initialize(clients_scope = Client.all)
    @clients = clients_scope
  end

  def call(params = {})
    @clients = apply_search(@clients, params)
    @clients = apply_sorting(@clients, params)
    @clients
  end

  private

  attr_reader :clients

  def apply_search(scope, params)
    return scope unless params[:search].present?

    search_term = params[:search]
    search_type = params[:search_type]

    case search_type
    when "name"
      scope.search_by_name(search_term)
    when "cpf"
      scope.search_by_cpf(search_term)
    when "phone"
      scope.search_by_phone(search_term)
    else
      # Busca geral usando o scope que combina os 3 campos
      scope.search_general(search_term)
    end
  end

  def apply_sorting(scope, params)
    sort_option = params[:sort]

    case sort_option
    when "name_asc"
      scope.order(:name)
    when "name_desc"
      scope.order(name: :desc)
    when "state_asc"
      scope.order(:state)
    when "state_desc"
      scope.order(state: :desc)
    when "created_at_asc"
      scope.order(:created_at)
    when "created_at_desc"
      scope.order(created_at: :desc)
    else
      scope.order(:name) # Padrão: nome ascendente
    end
  end
end

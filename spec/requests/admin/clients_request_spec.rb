# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Admin::Clients", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:client) { create(:client, user: user) }
  let(:other_user_client) { create(:client, user: other_user) }

  before do
    sign_in_user(user)
  end

  describe 'GET /admin/clients' do
    let(:cpf1) { CPF.generate }
    let(:cpf2) { CPF.generate }

    let!(:client1) {
      create(:client,
        user: user,
        name: 'João Silva',
        cpf: cpf1,
        phone: '(11) 11111-1111',
        address: 'Rua A, 123',
        city: 'São Paulo',
        state: 'SP'
      )
    }
    let!(:client2) {
      create(:client,
        user: user,
        name: 'Maria Santos',
        cpf: cpf2,
        phone: '(22) 22222-2222',
        address: 'Rua B, 456',
        city: 'Rio de Janeiro',
        state: 'RJ'
      )
    }
    let!(:other_client) { create(:client, user: other_user, name: 'Pedro Costa') }

    it 'returns a success response' do
      get admin_clients_path
      expect(response).to be_successful
    end

    it 'assigns only current user clients' do
      get admin_clients_path
      expect(assigns(:clients)).to include(client1, client2)
      expect(assigns(:clients)).not_to include(other_client)
    end

    context 'with search params' do
      it 'filters by name' do
        get admin_clients_path, params: { search: 'João', search_type: 'name' }
        expect(assigns(:clients)).to include(client1)
        expect(assigns(:clients)).not_to include(client2)
      end

      it 'filters by CPF' do
        get admin_clients_path, params: { search: client1.cpf, search_type: 'cpf' }
        expect(assigns(:clients)).to include(client1)
        expect(assigns(:clients)).not_to include(client2)
      end

      it 'performs general search when no search_type specified' do
        get admin_clients_path, params: { search: 'João' }
        expect(assigns(:clients)).to include(client1)
        expect(assigns(:clients)).not_to include(client2)
      end
    end

    context 'with sort params' do
      it 'sorts by name ascending' do
        get admin_clients_path, params: { sort: 'name', direction: 'asc' }
        clients = assigns(:clients).to_a
        expect(clients.first.name).to eq('João Silva')
        expect(clients.last.name).to eq('Maria Santos')
      end

      it 'sorts by name descending' do
        get admin_clients_path, params: { sort: 'name_desc' }
        clients = assigns(:clients).to_a
        expect(clients.first.name).to eq('Maria Santos')
        expect(clients.last.name).to eq('João Silva')
      end
    end
  end

  describe 'GET /admin/clients/:id' do
    it 'returns a success response' do
      get admin_client_path(client)
      expect(response).to be_successful
    end

    it 'assigns the requested client' do
      get admin_client_path(client)
      expect(assigns(:client)).to eq(client)
    end

    it 'prevents access to other user clients' do
      get admin_client_path(other_user_client)
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(admin_clients_path)
    end
  end

  describe 'GET /admin/clients/new' do
    it 'returns a success response' do
      get new_admin_client_path
      expect(response).to be_successful
    end

    it 'assigns a new client' do
      get new_admin_client_path
      expect(assigns(:client)).to be_a_new(Client)
    end
  end

  describe 'GET /admin/clients/:id/edit' do
    it 'returns a success response' do
      get edit_admin_client_path(client)
      expect(response).to be_successful
    end

    it 'assigns the requested client' do
      get edit_admin_client_path(client)
      expect(assigns(:client)).to eq(client)
    end

    it 'prevents editing other user clients' do
      get edit_admin_client_path(other_user_client)
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(admin_clients_path)
    end
  end

  describe 'POST /admin/clients' do
    let(:valid_attributes) {
      {
        name: 'Novo Cliente',
        address: 'Rua Teste, 123',
        city: 'São Paulo',
        state: 'SP',
        cep: '01234-567',
        phone: '(11) 99999-9999',
        cpf: CPF.generate
      }
    }

    context 'with valid params' do
      it 'creates a new Client' do
        expect {
          post admin_clients_path, params: { client: valid_attributes }
        }.to change(Client, :count).by(1)
      end

      it 'assigns the client to current user' do
        post admin_clients_path, params: { client: valid_attributes }
        expect(Client.last.user).to eq(user)
      end

      it 'redirects to the created client' do
        post admin_clients_path, params: { client: valid_attributes }
        expect(response).to redirect_to(admin_client_path(Client.last))
      end

      it 'sets a success notice' do
        post admin_clients_path, params: { client: valid_attributes }
        expect(flash[:notice]).to eq('Cliente foi criado com sucesso.')
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) { { name: '' } }

      it 'does not create a new Client' do
        expect {
          post admin_clients_path, params: { client: invalid_attributes }
        }.not_to change(Client, :count)
      end

      it 'renders the new template' do
        post admin_clients_path, params: { client: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'PUT /admin/clients/:id' do
    context 'with valid params' do
      let(:new_attributes) { { name: 'Cliente Atualizado' } }

      it 'updates the requested client' do
        put admin_client_path(client), params: { client: new_attributes }
        client.reload
        expect(client.name).to eq('Cliente Atualizado')
      end

      it 'redirects to the client' do
        put admin_client_path(client), params: { client: new_attributes }
        expect(response).to redirect_to(admin_client_path(client))
      end

      it 'sets a success notice' do
        put admin_client_path(client), params: { client: new_attributes }
        expect(flash[:notice]).to eq('Cliente foi atualizado com sucesso.')
      end
    end

    context 'with invalid params' do
      let(:invalid_attributes) { { name: '' } }

      it 'does not update the client' do
        original_name = client.name
        put admin_client_path(client), params: { client: invalid_attributes }
        client.reload
        expect(client.name).to eq(original_name)
      end

      it 'renders the edit template' do
        put admin_client_path(client), params: { client: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    it 'prevents updating other user clients' do
      put admin_client_path(other_user_client), params: { client: { name: 'Hack' } }
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(admin_clients_path)
    end
  end

  describe 'DELETE /admin/clients/:id' do
    it 'destroys the requested client' do
      client # Create the client
      expect {
        delete admin_client_path(client)
      }.to change(Client, :count).by(-1)
    end

    it 'redirects to the clients list' do
      delete admin_client_path(client)
      expect(response).to redirect_to(admin_clients_path)
    end

    it 'sets a success notice' do
      delete admin_client_path(client)
      expect(flash[:notice]).to eq('Cliente foi removido com sucesso.')
    end

    it 'prevents deleting other user clients' do
      delete admin_client_path(other_user_client)
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(admin_clients_path)
    end
  end

  describe 'authentication' do
    it 'redirects to login when not authenticated' do
      sign_out user
      get admin_clients_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end

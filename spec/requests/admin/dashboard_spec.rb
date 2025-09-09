require 'rails_helper'

RSpec.describe "Admin::Dashboards", type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, :admin) }

  describe "GET /admin" do
    context "when user is not authenticated" do
      it "redirects to login page" do
        get "/admin"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is authenticated" do
      before { sign_in user }

      it "returns http success" do
        get "/admin"
        expect(response).to have_http_status(:success)
      end

      it "renders the dashboard template" do
        get "/admin"
        expect(response).to render_template(:index)
      end

      it "displays the admin dashboard title" do
        get "/admin"
        expect(response.body).to include("Painel Administrativo")
      end

      it "displays the user's email in the dropdown" do
        get "/admin"
        expect(response.body).to include(user.email)
      end

      it "includes navigation links" do
        get "/admin"
        expect(response.body).to include("Clientes")
        expect(response.body).to include("Compromissos")
      end

      it "includes profile edit link" do
        get "/admin"
        expect(response.body).to include("Perfil")
      end

      it "includes logout link" do
        get "/admin"
        expect(response.body).to include("Sair")
      end
    end

    context "when admin user is authenticated" do
      before { sign_in admin }

      it "returns http success" do
        get "/admin"
        expect(response).to have_http_status(:success)
      end

      it "displays admin-specific content" do
        get "/admin"
        expect(response.body).to include("Daisy Panel - Admin")
      end
    end
  end
end

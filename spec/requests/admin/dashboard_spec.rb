require 'rails_helper'

RSpec.describe "Admin::Dashboards", type: :request do
  include ActiveSupport::Testing::TimeHelpers
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
      before { sign_in_user(user) }

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
      before { sign_in_user(admin) }

      it "returns http success" do
        get "/admin"
        expect(response).to have_http_status(:success)
      end

      it "displays admin-specific content" do
        get "/admin"
        expect(response.body).to include("Admin - Daisy Panel")
      end
    end
  end

  describe "GET /admin/dashboard/clients_chart_data" do
    context "when user is not authenticated" do
      it "redirects to login page" do
        get "/admin/dashboard/clients_chart_data"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is authenticated" do
      before { sign_in_user(user) }

      it "returns http success" do
        get "/admin/dashboard/clients_chart_data"
        expect(response).to have_http_status(:success)
      end

      it "returns JSON with chart data structure" do
        get "/admin/dashboard/clients_chart_data"

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("labels")
        expect(json_response).to have_key("values")
        expect(json_response["labels"]).to be_an(Array)
        expect(json_response["values"]).to be_an(Array)
        expect(json_response["labels"].length).to eq(30)
        expect(json_response["values"].length).to eq(30)
      end

      it "includes clients created in the last 30 days" do
        travel_to 10.days.ago do
          create(:client, user: user)
          create(:client, user: user)
        end
        travel_to 5.days.ago do
          create(:client, user: user)
        end

        get "/admin/dashboard/clients_chart_data"

        json_response = JSON.parse(response.body)
        total_clients = json_response["values"].sum
        expect(total_clients).to eq(3)
      end

      it "does not include clients from other users" do
        other_user = create(:user)
        create(:client, user: other_user)
        create(:client, user: user)

        get "/admin/dashboard/clients_chart_data"

        json_response = JSON.parse(response.body)
        total_clients = json_response["values"].sum
        expect(total_clients).to eq(1)
      end

      it "does not include clients older than 30 days" do
        travel_to 35.days.ago do
          create(:client, user: user)
        end
        create(:client, user: user)

        get "/admin/dashboard/clients_chart_data"

        json_response = JSON.parse(response.body)
        total_clients = json_response["values"].sum
        expect(total_clients).to eq(1)
      end
    end
  end

  describe "GET /admin/dashboard/appointments_data" do
    context "when user is not authenticated" do
      it "redirects to login page" do
        get "/admin/dashboard/appointments_data"
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is authenticated" do
      before { sign_in_user(user) }

      it "returns http success" do
        get "/admin/dashboard/appointments_data"
        expect(response).to have_http_status(:success)
      end

      it "returns JSON with chart data structure" do
        get "/admin/dashboard/appointments_data"

        json_response = JSON.parse(response.body)
        expect(json_response).to have_key("labels")
        expect(json_response).to have_key("values")
        expect(json_response["labels"]).to be_an(Array)
        expect(json_response["values"]).to be_an(Array)
        expect(json_response["labels"].length).to eq(30)
        expect(json_response["values"].length).to eq(30)
      end

      it "includes appointments created in the last 30 days" do
        travel_to 10.days.ago do
          create(:appointment, user: user)
          create(:appointment, user: user)
        end
        travel_to 5.days.ago do
          create(:appointment, user: user)
        end

        get "/admin/dashboard/appointments_data"

        json_response = JSON.parse(response.body)
        total_appointments = json_response["values"].sum
        expect(total_appointments).to eq(3)
      end

      it "does not include appointments from other users" do
        other_user = create(:user)
        create(:appointment, user: other_user)
        create(:appointment, user: user)

        get "/admin/dashboard/appointments_data"

        json_response = JSON.parse(response.body)
        total_appointments = json_response["values"].sum
        expect(total_appointments).to eq(1)
      end

      it "does not include appointments older than 30 days" do
        travel_to 35.days.ago do
          create(:appointment, user: user)
        end
        create(:appointment, user: user)

        get "/admin/dashboard/appointments_data"

        json_response = JSON.parse(response.body)
        total_appointments = json_response["values"].sum
        expect(total_appointments).to eq(1)
      end
    end
  end
end

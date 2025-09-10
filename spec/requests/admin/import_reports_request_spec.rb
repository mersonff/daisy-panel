require 'rails_helper'

RSpec.describe "Admin::ImportReports", type: :request do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:import_report1) { create(:import_report, user: user, created_at: 2.days.ago) }
  let!(:import_report2) { create(:import_report, user: user, created_at: 1.day.ago) }
  let!(:other_user_report) { create(:import_report, user: other_user) }

  before do
    sign_in_user(user)
  end

  describe 'GET /admin/import_reports' do
    it 'returns a success response' do
      get admin_import_reports_path
      expect(response).to be_successful
    end

    it 'assigns only current user import reports' do
      get admin_import_reports_path
      expect(assigns(:import_reports)).to include(import_report1, import_report2)
      expect(assigns(:import_reports)).not_to include(other_user_report)
    end

    it 'orders reports by most recent first' do
      get admin_import_reports_path
      reports = assigns(:import_reports).to_a
      expect(reports.first).to eq(import_report2) # more recent
      expect(reports.last).to eq(import_report1)  # older
    end

    it 'limits to 20 reports' do
      # Create 25 reports
      25.times { create(:import_report, user: user) }

      get admin_import_reports_path
      expect(assigns(:import_reports).count).to eq(20)
    end

    it 'renders the index template' do
      get admin_import_reports_path
      expect(response).to render_template(:index)
    end
  end

  describe 'GET /admin/import_reports/:id' do
    it 'returns a success response' do
      get admin_import_report_path(import_report1)
      expect(response).to be_successful
    end

    it 'assigns the requested import report' do
      get admin_import_report_path(import_report1)
      expect(assigns(:import_report)).to eq(import_report1)
    end

    it 'assigns the errors list' do
      error_details = [
        { "line" => 2, "name" => "Test User", "cpf" => "12345678900", "errors" => [ "Nome inválido" ] }
      ]
      import_report1.update(error_details: error_details)

      get admin_import_report_path(import_report1)
      expect(assigns(:errors)).to eq(error_details)
    end

    it 'renders the show template' do
      get admin_import_report_path(import_report1)
      expect(response).to render_template(:show)
    end

    it 'prevents access to other user reports' do
      get admin_import_report_path(other_user_report)
      expect(response).not_to be_successful
    end
  end

  describe 'GET /admin/import_reports/latest' do
    context 'when user has import reports' do
      it 'redirects to the most recent import report' do
        get latest_admin_import_reports_path
        expect(response).to redirect_to(admin_import_report_path(import_report2))
      end

      it 'returns a redirect response' do
        get latest_admin_import_reports_path
        expect(response).to have_http_status(:found)
      end
    end

    context 'when user has no import reports' do
      before do
        user.import_reports.destroy_all
      end

      it 'redirects to clients path with notice' do
        get latest_admin_import_reports_path
        expect(response).to redirect_to(admin_clients_path)
      end

      it 'sets a notice message' do
        get latest_admin_import_reports_path
        expect(flash[:notice]).to eq("Nenhuma importação encontrada.")
      end
    end

    context 'when other users have reports but current user does not' do
      before do
        user.import_reports.destroy_all
      end

      it 'redirects to clients path' do
        # other_user_report exists but should not affect current user
        get latest_admin_import_reports_path
        expect(response).to redirect_to(admin_clients_path)
      end
    end
  end

  describe 'authentication' do
    context 'when not authenticated' do
      before do
        sign_out user
      end

      it 'redirects to login for index' do
        get admin_import_reports_path
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'redirects to login for show' do
        get admin_import_report_path(import_report1)
        expect(response).to redirect_to(new_user_session_path)
      end

      it 'redirects to login for latest' do
        get latest_admin_import_reports_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe 'authorization' do
    it 'only shows reports belonging to current user' do
      get admin_import_reports_path

      assigned_reports = assigns(:import_reports)
      user_ids = assigned_reports.pluck(:user_id).uniq

      expect(user_ids).to eq([ user.id ])
      expect(user_ids).not_to include(other_user.id)
    end
  end
end

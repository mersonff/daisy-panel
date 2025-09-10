require 'rails_helper'

RSpec.describe "Users::Registrations", type: :request do
  let(:user) { create(:user) }

  describe "GET /users/sign_up" do
    it "redirects to login page" do
      get new_user_registration_path
      expect(response).to redirect_to(new_user_session_path)
    end

    it "sets a flash alert message" do
      get new_user_registration_path
      follow_redirect!
      expect(flash[:alert]).to eq("Registro público não permitido. Entre em contato com o administrador.")
    end
  end

  describe "POST /users" do
    it "redirects to login page" do
      post user_registration_path, params: { user: { email: 'test@example.com', password: 'password123' } }
      expect(response).to redirect_to(new_user_session_path)
    end

    it "sets a flash alert message" do
      post user_registration_path, params: { user: { email: 'test@example.com', password: 'password123' } }
      follow_redirect!
      expect(flash[:alert]).to eq("Registro público não permitido. Entre em contato com o administrador.")
    end

    it "does not create a new user" do
      expect {
        post user_registration_path, params: { user: { email: 'test@example.com', password: 'password123' } }
      }.not_to change(User, :count)
    end
  end

  describe "GET /users/edit" do
    context "when user is not authenticated" do
      it "redirects to login page" do
        get edit_user_registration_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is authenticated" do
      before { sign_in user }

      it "returns http success" do
        get edit_user_registration_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "PATCH /users" do
    context "when user is not authenticated" do
      it "redirects to login page" do
        patch user_registration_path, params: { user: { email: 'new@example.com' } }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is authenticated" do
      before { sign_in user }

      context "with valid parameters" do
        let(:valid_params) do
          {
            email: 'newemail@example.com',
            current_password: 'password123'
          }
        end

        it "updates the user" do
          patch user_registration_path, params: { user: valid_params }
          user.reload
          expect(user.email).to eq('newemail@example.com')
        end

        it "redirects after update" do
          patch user_registration_path, params: { user: valid_params }
          expect(response).to be_redirect
        end
      end

      context "with invalid parameters" do
        let(:invalid_params) do
          {
            email: 'invalid-email',
            current_password: 'password123'
          }
        end

        it "does not update the user" do
          original_email = user.email
          patch user_registration_path, params: { user: invalid_params }
          user.reload
          expect(user.email).to eq(original_email)
        end

        it "returns unprocessable entity" do
          patch user_registration_path, params: { user: invalid_params }
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe "DELETE /users" do
    context "when user is not authenticated" do
      it "redirects to login page" do
        delete user_registration_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when user is authenticated" do
      before { sign_in user }

      it "prevents account deletion" do
        delete user_registration_path
        expect(response).to redirect_to(edit_user_registration_path)
      end

      it "sets a flash alert message" do
        delete user_registration_path
        follow_redirect!
        expect(flash[:alert]).to eq("Exclusão de conta não permitida. Entre em contato com o administrador.")
      end

      it "does not delete the user" do
        expect {
          delete user_registration_path
        }.not_to change(User, :count)
      end

      it "keeps the user in the database" do
        delete user_registration_path
        expect(User.find(user.id)).to eq(user)
      end
    end
  end
end

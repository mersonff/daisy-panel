class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, except: [:new, :create]

  # Disable new user registration
  def new
    redirect_to new_user_session_path, alert: "Registro público não permitido. Entre em contato com o administrador."
  end

  def create
    redirect_to new_user_session_path, alert: "Registro público não permitido. Entre em contato com o administrador."
  end

  # Allow existing users to edit their profile
  def edit
    super
  end

  def update
    super
  end

  # Prevent account deletion for security
  def destroy
    redirect_to edit_user_registration_path,
                alert: "Exclusão de conta não permitida. Entre em contato com o administrador."
  end

  protected

  # Redirect after update
  def after_update_path_for(resource)
    admin_root_path
  end
end

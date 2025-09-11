class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Include Pagy helper
  include Pagy::Backend

  # Handle record not found errors
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  protected

  def after_sign_in_path_for(resource)
    dashboard_path
  end

  def health
    render json: { status: "ok", timestamp: Time.current }
  end

  private

  def record_not_found
    redirect_to admin_clients_path, alert: "Cliente não encontrado"
  end
end

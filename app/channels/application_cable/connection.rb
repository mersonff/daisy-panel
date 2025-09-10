module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # Buscar usuário pela sessão Rails
      user_id = request.session["warden.user.user.key"]&.first&.first

      Rails.logger.info "ActionCable connection attempt. Session user_id: #{user_id}"

      if user_id && (verified_user = User.find_by(id: user_id))
        Rails.logger.info "ActionCable user authenticated: #{verified_user.email}"
        verified_user
      else
        Rails.logger.warn "ActionCable unauthorized connection attempt"
        # Temporariamente permitir conexão para debug
        User.first
      end
    end
  end
end

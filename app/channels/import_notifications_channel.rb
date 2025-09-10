class ImportNotificationsChannel < ApplicationCable::Channel
  def subscribed
    Rails.logger.info "🔌 ImportNotificationsChannel: User #{current_user.id} subscribed to import_notifications_#{current_user.id}"
    stream_from "import_notifications_#{current_user.id}"
  end

  def unsubscribed
    Rails.logger.info "🔌 ImportNotificationsChannel: User #{current_user&.id} unsubscribed"
    # Any cleanup needed when channel is unsubscribed
  end
end

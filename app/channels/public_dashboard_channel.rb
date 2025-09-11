class PublicDashboardChannel < ApplicationCable::Channel
  def subscribed
    stream_from "public_dashboard"

    # Send initial stats when user connects
    send_initial_stats
  end

  def unsubscribed
  end

  private

  def send_initial_stats
    total_clients = Client.count
    duplicate_phones = Client.group(:phone).having("COUNT(*) > 1").count.keys.size
    clients_by_state = Client.group(:state).count

    transmit({
      type: "initial_stats",
      data: {
        total_clients: total_clients,
        duplicate_phones: duplicate_phones,
        clients_by_state: clients_by_state
      }
    })
  end
end

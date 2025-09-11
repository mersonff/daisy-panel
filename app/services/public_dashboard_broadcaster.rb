class PublicDashboardBroadcaster
  def self.broadcast_stats
    total_clients = Client.count
    duplicate_phones = Client.group(:phone).having("COUNT(*) > 1").count.keys.size
    clients_by_state = Client.group(:state).count

    ActionCable.server.broadcast(
      "public_dashboard",
      {
        type: "stats_update",
        data: {
          total_clients: total_clients,
          duplicate_phones: duplicate_phones,
          clients_by_state: clients_by_state
        }
      }
    )
  end
end

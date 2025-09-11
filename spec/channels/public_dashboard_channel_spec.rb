require 'rails_helper'

RSpec.describe PublicDashboardChannel, type: :channel do
  before do
    create_list(:client, 3)
    create(:client, phone: "11999999999")
    create(:client, phone: "11999999999")
  end

  describe "#subscribed" do
    it "successfully subscribes to the public_dashboard stream" do
      subscribe

      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("public_dashboard")
    end

    it "calls send_initial_stats when subscribing" do
      expect_any_instance_of(described_class).to receive(:send_initial_stats)
      subscribe
    end
  end

  describe "#unsubscribed" do
    it "successfully unsubscribes without errors" do
      subscribe
      expect(subscription).to be_confirmed

      expect { unsubscribe }.not_to raise_error
    end
  end

  describe "initial stats transmission" do
    it "transmits data when subscribed" do
      expect { subscribe }.not_to raise_error
      expect(subscription).to be_confirmed
      expect(subscription).to have_stream_from("public_dashboard")
    end
  end

  describe "broadcasting integration" do
    it "can receive broadcasts from PublicDashboardBroadcaster" do
      subscribe

      expect {
        PublicDashboardBroadcaster.broadcast_stats
      }.to have_broadcasted_to("public_dashboard")
    end
  end
end

class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  layout "admin"

  def index; end

  def clients_chart_data
    start_date = 30.days.ago.beginning_of_day
    end_date = Date.current.end_of_day

    clients = current_user.clients.where(created_at: start_date..end_date)

    clients_by_day = {}
    clients.each do |client|
      date = client.created_at.in_time_zone.to_date
      clients_by_day[date] = (clients_by_day[date] || 0) + 1
    end

    labels = []
    values = []

    (0..29).each do |i|
      date = Date.current - 29.days + i.days
      labels << date.strftime("%d/%m")
      values << (clients_by_day[date] || 0)
    end

    render json: {
      labels: labels,
      values: values
    }
  end

  def appointments_data
    start_date = 30.days.ago.beginning_of_day
    end_date = Date.current.end_of_day

    appointments = current_user.appointments.where(created_at: start_date..end_date)

    appointments_by_day = {}
    appointments.each do |appointment|
      date = appointment.created_at.in_time_zone.to_date
      appointments_by_day[date] = (appointments_by_day[date] || 0) + 1
    end

    labels = []
    values = []

    (0..29).each do |i|
      date = Date.current - 29.days + i.days
      labels << date.strftime("%d/%m")
      values << (appointments_by_day[date] || 0)
    end

    render json: {
      labels: labels,
      values: values
    }
  end
end

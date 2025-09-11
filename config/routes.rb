Rails.application.routes.draw do
  # Health check endpoint for AWS
  get "health", to: "application#health"

  # Mount ActionCable
  mount ActionCable.server => "/cable"

  # Devise routes with custom registrations controller
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  # Public pages
  root to: "pages#home"
  get "home", to: "pages#home"

  # Dashboard (authenticated users)
  get "dashboard", to: "admin/dashboard#index"

  # Admin panel
  namespace :admin do
    root to: "dashboard#index"
    get "dashboard/clients_chart_data", to: "dashboard#clients_chart_data"
    get "dashboard/appointments_data", to: "dashboard#appointments_data"
    resources :clients do
      collection do
        post :import_csv
      end
    end

    resources :import_reports, only: [ :index, :show ] do
      collection do
        get :latest
      end
    end

    resources :appointments
  end
end

Rails.application.routes.draw do
  # Devise routes with custom registrations controller
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  # Public pages (dashboard)
  root to: "pages#home"

  # Admin panel
  namespace :admin do
    root to: "dashboard#index"
    # resources :clients
    # resources :appointments
  end
end

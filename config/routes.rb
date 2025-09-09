Rails.application.routes.draw do
  # Devise routes with custom registrations controller
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  # Public pages
  root to: "pages#home"
  get 'home', to: 'pages#home'

  # Dashboard (authenticated users)
  get 'dashboard', to: 'admin/dashboard#index'

  # Admin panel
  namespace :admin do
    root to: "dashboard#index"
    # resources :clients
    # resources :appointments
  end
end

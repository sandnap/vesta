Rails.application.routes.draw do
  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authentication routes
  resource :session
  resources :passwords, param: :token
  resource :signup, only: [ :new, :create ]

  # Main application routes
  resources :portfolios do
    member do
      post :refresh_investment_prices
    end
    resource :note_draft, only: [ :show, :create, :update, :destroy ]
    resources :transactions, only: [ :new, :create ]
    resources :investments, except: [ :index ] do
      resources :transactions do
        collection do
          get :export
        end
      end
      resource :note_draft, only: [ :show, :create, :update, :destroy ]
      resources :notes, except: [ :index, :show ]
    end
    resources :notes, except: [ :index, :show ]
  end

  resource :settings, only: [ :show ] do
    patch :update_password, on: :collection
    patch :disable_user, on: :collection
  end

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Root route
  root "home#index"
end

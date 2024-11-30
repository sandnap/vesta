Rails.application.routes.draw do
  # Authentication routes
  resource :session
  resources :passwords, param: :token

  # Main application routes
  resources :portfolios do
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

  # Health check route
  get "up" => "rails/health#show", as: :rails_health_check

  # Root route
  root "home#index"
end

Rails.application.routes.draw do
  # === Posts ===
  get "posts/page/:page", to: "posts#index", as: :posts_page, constraints: { page: /\d+/ }
  resources :posts do
    collection do
      get "category/:category", action: :index, as: :category
      get "tag/:tag", action: :tag, as: :tag
      get "archive/:year", action: :archive, as: :archive, constraints: { year: /\d{4}/ }
    end
  end
  get "search/:keyword", to: "posts#search", as: :search

  # === Admin Session ===
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Dynamic thumbnail generation
  get "thumbnails/:filename", to: "thumbnails#show", as: :thumbnail, constraints: { filename: /.+/ }

  # TinyMCE Editor image upload (Active Storage)
  post "uploads/image", to: "uploads#image"
  delete "uploads/image", to: "uploads#destroy_image"

  # Defines the root path route ("/")
  root "posts#index"

  # === Error Pages ===
  get "/404", to: "errors#not_found"
  get "/422", to: "errors#unprocessable"
  get "/500", to: "errors#internal_server"
end

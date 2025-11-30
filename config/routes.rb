Rails.application.routes.draw do
  get "posts/category/:category", to: "posts#index", as: :category_posts
  get "posts/page/:page", to: "posts#index", as: :posts_page

  resources :posts
  get "search/:keyword", to: "posts#search", as: :search
  get "posts/archive/:year", to: "posts#archive", as: :archive, constraints: { year: /\d{4}/ }

  # Admin session routes
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

  # Defines the root path route ("/")
  root "posts#index"
end

Rails.application.routes.draw do
  # API Documentation (Swagger UI)
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  get    "signin", to: "sessions#new"
  post   "signin", to: "sessions#create"
  delete "signin", to: "sessions#destroy"
  get    "signup", to: "registrations#new"
  post   "signup", to: "registrations#create"

  # Magic Link & OTP 인증
  get "magic_link/:token", to: "sessions#magic_link", as: :magic_link
  get "otp_verification", to: "sessions#otp_verification"

  # Members API
  namespace :members do
    namespace :api do
      get    "member",            to: "member#show"
      put    "member",            to: "member#update"
      delete "member",            to: "member#destroy"
      get    "session",           to: "session#show"
      delete "session",           to: "session#destroy"
      post   "member/email",      to: "member#update_email"
      get    "integrity-token",   to: "integrity_token#show"
      post   "send-magic-link",   to: "magic_link#create"
      post   "verify-otp",        to: "otp#create"
    end
  end

  resources :sessions, only: [ :index, :show, :destroy ]
  namespace :identity do
    resource :email,              only: [ :edit, :update ]
    resource :email_verification, only: [ :show, :create ]
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Root route
  root "home#index"

  # Blog routes
  resources :posts, only: [ :index ]
  get "category/:name", to: "categories#show", as: "category"
  get "author/:name", to: "authorities#show", as: "author"

  # Image serving routes (static files in public/ are served automatically)
  # get "assets/images/size/:size/format/:format/*path", to: "images#show", as: "responsive_image"

  # Phase 3 routes
  get "search", to: "search#index", as: "search"
  get "authorization", to: "authorization#index", as: "authorization"

  # Future routes (Phase 4)
  # get "about", to: "pages#about"
  # get "projects", to: "pages#projects"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Individual post routes (must be last to avoid conflicts)
  get ":slug", to: "posts#show", as: "post_by_slug", constraints: { slug: /[a-z0-9\-]+/ }
end

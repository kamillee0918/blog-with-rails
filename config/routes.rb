Rails.application.routes.draw do
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

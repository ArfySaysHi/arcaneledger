Rails.application.routes.draw do
  post "sign_up", to: "users#create"
  resources :confirmations, only: [ :create, :edit ], param: :confirmation_token

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end

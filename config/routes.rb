# frozen_string_literal: true

Rails.application.routes.draw do
  # UsersController
  post 'sign_up', to: 'users#create'
  patch 'account', to: 'users#update'
  delete 'account', to: 'users#destroy'

  # SessionsController
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  # ConfirmationsController
  resources :confirmations, only: %i[create edit], param: :confirmation_token

  # PasswordsController
  resources :passwords, only: %i[create update], param: :password_reset_token

  # ActiveSessionsController
  resources :active_sessions, only: %i[destroy] do
    collection do
      delete "destroy_all"
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check
end

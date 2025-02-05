# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'
  resources :users, only: %i[new create]
  post '/verify', to: 'users#verify', as: 'verify_user'
  delete '/logout', to: 'users#logout', as: 'logout' # Добавили выход
end

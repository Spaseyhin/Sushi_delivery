# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users, only: %i[new create]
  post '/verify', to: 'users#verify', as: 'verify_user'
  delete '/logout', to: 'users#logout', as: 'logout' # Выход пользователя

  resources :products, only: %i[index show]
  resource :cart, only: [:show] # Одна корзина на пользователя
  resources :cart_items, only: %i[create update destroy]
  resources :orders, only: %i[create index show]

  # Корректно монтируем ActiveStorage один раз:
  mount ActiveStorage::Engine => '/rails/active_storage'

  # Рутовый маршрут
  root 'products#index'
end

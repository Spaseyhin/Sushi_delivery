# frozen_string_literal: true

Rails.application.routes.draw do
  get 'pages/about'
  scope '(:locale)', locale: /en|ru/ do
    devise_for :admin_users, controllers: {
      sessions: 'admin_users/sessions'
    }

    # маршрут для админки
    namespace :admin do
      resources :products
      resources :orders, only: [:index]
      root to: 'home#index'
    end

    resources :users, only: [] do
      get :address, on: :collection
      patch :update_address, on: :collection
    end

    resources :users, only: %i[new create]
    post '/verify', to: 'users#verify', as: 'verify_user'
    delete '/logout', to: 'users#logout', as: 'logout'

    resources :products, only: %i[index show]
    resource :cart, only: [:show]
    resources :cart_items, only: %i[create update destroy]
    resources :orders, only: %i[create index show]
    get '/about', to: 'pages#about', as: 'about'

    root 'products#index'
  end

  # ActiveStorage можно монтировать вне scope — он не требует локали
  mount ActiveStorage::Engine => '/rails/active_storage'
end

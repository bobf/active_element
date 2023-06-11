# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  root to: 'admin/examples#index'

  resources :examples
  resources :components
  resources :examples
  resources :example_permissions do
    member do
      get 'custom'
      get 'unprotected'
    end
  end

  resources :users

  namespace :admin do
    resources :examples
    resources :permitted_alternatives
  end
end

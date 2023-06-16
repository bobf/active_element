Rails.application.routes.draw do
  devise_for :users

  root to: 'pets#index'

  resources :pets
  resources :users
end

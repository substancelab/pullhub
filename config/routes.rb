# frozen_string_literal: true
Rails.application.routes.draw do
  devise_for :users, :controllers => {:omniauth_callbacks => "users/omniauth_callbacks"}

  resources :dashboard

  root to: 'dashboard#index'
end

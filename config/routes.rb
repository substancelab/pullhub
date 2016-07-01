# frozen_string_literal: true
Rails.application.routes.draw do
  resources :dashboard

  root to: 'dashboard#index'
end

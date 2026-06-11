# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users
  resources :tags

  get 'tasks', to: 'tasks#index'

  namespace :tasks do
    resources :one_offs, only: %i[show create update destroy]
    namespace :recurring do
      resources :templates, only: :create do
        resources :overrides, only: %i[show update destroy]
      end
    end
  end
end

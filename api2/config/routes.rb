# frozen_string_literal: true

Rails.application.routes.draw do
  scope defaults: { format: 'json' } do
    post 'sessions', to: 'sessions#create'
    delete 'sessions', to: 'sessions#destroy'

    post 'graphql', to: 'graphql#execute'
  end
end

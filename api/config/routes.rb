Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :answers
  resources :application
  resources :attachments
  resources :comments
  resources :contests
  resources :issues
  resources :members
  resources :notices
  resources :notifications
  resources :problem_groups
  resources :problems
  resources :scoreboards
  resources :scores
  resources :teams
end

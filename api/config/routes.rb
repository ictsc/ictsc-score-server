Rails.application.routes.draw do
  scope '/api' do
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
    resources :sessions, only: [:show, :create, :destroy]
    resources :teams
  end
end

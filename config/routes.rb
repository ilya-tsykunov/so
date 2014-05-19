Rails.application.routes.draw do
  devise_for :users

  resources :questions do
    resources :answers
  end

  concern :commentable do
    resources :comments
  end

  resources :questions, :answers, concerns: :commentable

  root 'questions#index'
end
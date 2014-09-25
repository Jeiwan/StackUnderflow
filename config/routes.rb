Rails.application.routes.draw do
  devise_for :users

  concern :commentable do
    resources :comments, only: [:create, :edit, :update, :destroy]
  end

  resources :questions, concerns: :commentable do
    resources :answers, only: [:new, :create, :edit, :update, :destroy], concerns: :commentable do
      post "mark_best", on: :member
    end
  end

  resources :answers, only: [], concerns: :commentable

  root "questions#index"
end

Rails.application.routes.draw do
  devise_for :users

  concern :commentable do
    resources :comments, only: [:create, :edit, :update, :destroy]
  end

  resources :questions, concerns: :commentable do
    resources :answers, only: [:new, :create, :edit, :update, :destroy], shallow: true, concerns: :commentable do
      post "mark_best", on: :member
    end
  end

  root "questions#index"
end

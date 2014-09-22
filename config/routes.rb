Rails.application.routes.draw do
  devise_for :users
  resources :questions do
    resources :answers, only: [:new, :create, :edit, :update, :destroy] do
      post "mark_best", on: :member
    end
    resources :comments, only: [:create, :edit, :update, :destroy]
  end

  resources :answer, only: [] do
    resources :comments, only: [:create, :edit, :update, :destroy]
  end

  root "questions#index"
end

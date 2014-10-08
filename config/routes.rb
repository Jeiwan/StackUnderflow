Rails.application.routes.draw do
  devise_for :users

  concern :commentable do
    resources :comments, only: [:create, :edit, :update, :destroy]
  end

  concern :votable do
    patch "/vote_up" => "votes#vote_up", as: :vote_up
    patch "/vote_down" => "votes#vote_down", as: :vote_down
  end

  resources :questions, concerns: [:commentable, :votable] do
    resources :answers, only: [:new, :create, :edit, :update, :destroy], concerns: :commentable do
      post "mark_best", on: :member
    end
  end

  resources :answers, only: [], concerns: :commentable
  resources :tags, only: [:index]

  patch "/questions/:id/vote/:vote" => "questions#vote", as: :question_vote

  root "questions#index"
end

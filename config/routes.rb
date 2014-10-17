Rails.application.routes.draw do
  devise_for :users

  concern :commentable do
    resources :comments, only: [:create, :edit, :update, :destroy], concerns: :votable
  end

  concern :votable do
    patch :vote_up, on: :member, controller: :votes
    patch :vote_down, on: :member, controller: :votes
  end

  resources :questions, concerns: [:commentable, :votable], shallow: true do
    resources :answers, only: [:new, :create, :edit, :update, :destroy], shallow: true, concerns: [:commentable, :votable] do
      post "mark_best", on: :member
    end
    collection do
      get "/tag/:tag_name", to: "questions#show_by_tag", as: :show_by_tag
      get "/sort/votes", to: "questions#sort_by_votes", as: :sort_by_votes
    end
  end

  resources :tags, only: [:index]

  resources :attachments, only: [:destroy]

  root "questions#index"
end

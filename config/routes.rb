Rails.application.routes.draw do
  devise_for :users, controllers: {omniauth_callbacks: 'omniauth_callbacks'}

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
    #collection do
      #get "/tag/:tag_name", to: "questions#tagged_with", as: :tagged
      #get "/popular", to: "questions#popular", as: :popular
      #get "/unanswered", to: "questions#unanswered", as: :unanswered
      #get "/active", to: "questions#active", as: :active
    #end
  end

  resources :tags, only: [:index] do
    collection do
      get "/alphabetical", to: "tags#alphabetical", as: :alphabetical
      get "/newest", to: "tags#newest", as: :newest
    end
  end

  resources :attachments, only: [:destroy]

  resources :users, only: [:show, :edit, :update], param: :username

  root "questions#index"
end

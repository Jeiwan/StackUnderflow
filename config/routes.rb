Rails.application.routes.draw do
  use_doorkeeper
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
  end

  resources :tags, only: [:index] do
    collection do
      get "/alphabetical", to: "tags#alphabetical", as: :alphabetical
      get "/newest", to: "tags#newest", as: :newest
    end
  end

  resources :attachments, only: [:destroy]

  resources :users, only: [:index, :show, :edit, :update], param: :username do
    get "/logins" => "users#logins", as: :logins, on: :member
  end

  namespace :api do
    namespace :v1 do
      resource :profiles do
        get :me, on: :collection
      end
      resources :questions
      resources :users, param: :username
    end
  end

  root "questions#index"
end

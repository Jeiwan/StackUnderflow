require 'sidekiq/web'

Rails.application.routes.draw do
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
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

    collection do
      get "popular(/page/:page)" => "questions#popular", as: :popular
      get "unanswered(/page/:page)" => "questions#unanswered", as: :unanswered
      get "active(/page/:page)" => "questions#active", as: :active
      get "tagged/:tag(/page/:page)" => "questions#tagged", as: :tagged
    end

    post "add_favorite" => "questions#add_favorite", as: :add_favorite
    post "remove_favorite" => "questions#remove_favorite", as: :remove_favorite
  end

  resources :tags, only: :index do
    collection do
      get "/(page/:page)", to: "tags#index"
      get "/newest(/page/:page)", to: "tags#newest", as: :newest
      get "/popular(/page/:page)", to: "tags#popular", as: :popular
    end
  end

  resources :attachments, only: [:destroy]

  resources :users, only: [:index, :show, :edit, :update], param: :username do
    get "/logins" => "users#logins", as: :logins, on: :member

    collection do
      get "/by_registration(/page/:page)", to: "users#by_registration", as: :by_registration
      get "/alphabetically(/page/:page)", to: "users#alphabetically", as: :alphabetically
    end
  end

  namespace :api do
    namespace :v1 do
      resources :questions, only: [:index, :show, :create], shallow: true do
        resources :answers, only: [:index, :show, :create], shallow: true
      end
      resources :users, only: [:index, :show], param: :username
      get "/profile", to: "users#profile", as: :profile
    end
  end

  root "questions#index"
end

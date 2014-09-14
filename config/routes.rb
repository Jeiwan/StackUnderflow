Rails.application.routes.draw do
  devise_for :users
	resources :questions, except: [:destroy] do
		resources :answers, only: [:create]
	end

	root "questions#index"
end

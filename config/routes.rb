Rails.application.routes.draw do
  devise_for :users
	resources :questions do
		resources :answers, only: [:create, :edit, :update]
	end

	root "questions#index"
end

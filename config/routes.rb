Rails.application.routes.draw do
	resources :questions, only: [:index, :new, :create, :show] do
		resources :answers, only: [:create]
	end

	root "questions#index"
end

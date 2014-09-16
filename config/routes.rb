Rails.application.routes.draw do
  devise_for :users
	resources :questions do
		resources :answers, only: [:create, :edit, :update, :destroy]
		post "/answers/:id/best" => "answers#mark_best", as: "mark_best_answer"
	end

	root "questions#index"
end

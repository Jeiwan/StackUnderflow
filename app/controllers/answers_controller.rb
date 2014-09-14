class AnswersController < ApplicationController

	before_action :must_be_logged_in, only: [:create]

	def create
		@question = Question.find(params[:question_id])
		@answer = @question.answers.new(answer_params)

		if @answer.save
			current_user.answers << @answer
			flash[:success] = "Answer is created!"
		else
			flash[:danger] = "Wrong length of answer!"
		end
		redirect_to @question
	end

	def show
		@question = Question.find(params[:question_id])
		@answers = @question.answers
		@answer = Answer.new
		render "questions#show"
	end

	private
		
		def answer_params
			params.require(:answer).permit(:body)
		end

		def must_be_logged_in
			unless user_signed_in?
				flash[:danger] = "You must be logged in to post an answer."
				redirect_to root_path
			end
		end
end

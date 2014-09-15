class AnswersController < ApplicationController

	before_action :must_be_logged_in, only: [:create, :edit, :update]

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

	def edit
		@answer = Answer.find(params[:id])
	end

	def update
		@answer = Answer.find(params[:id])

		if @answer.update(answer_params)
			flash[:success] = "Answer is updated!"
			redirect_to question_answer_path(@answer.question.id, @answer.id)
		else
			render "edit"
		end
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

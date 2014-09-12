class AnswersController < ApplicationController
	def create
		@question = Question.find(params[:question_id])
		@answer = @question.answers.new(answer_params)

		if @answer.save
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
end

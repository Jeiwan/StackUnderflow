class QuestionsController < ApplicationController
	def index
		@questions = Question.all
	end

	def new
		@question = Question.new
	end

	def show
		@question = Question.find(params[:id])
		@answers = @question.answers
		@answer = Answer.new
	end

	def create
		@question = Question.new(question_params)
		
		if @question.save
			flash[:success] = "Question is created!"
			redirect_to @question
		else
			render "new"
		end
	end

	private

		def question_params
			params.require(:question).permit(:title, :body)
		end
end

class QuestionsController < ApplicationController
	before_action :must_be_logged_in, except: [ :index, :show ]

	def index
		@questions = Question.all.order("created_at DESC")
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
		@question = current_user.questions.new(question_params)
		
		if @question.save
			flash[:success] = "Question is created!"
			redirect_to @question
		else
			render "new"
		end
	end

	def edit
		@question = current_user.questions.find(params[:id])
		redirect_to question_path(params[:id]) if @question.nil?
	end

	def update
		@question = current_user.questions.find(params[:id])

		if @question.update(question_params)
			flash[:success] = "Question updated!"
			redirect_to @question
		else
			render "edit"
		end
	end

	def destroy
		@question = current_user.questions.find(params[:id])
		@question.destroy
		flash[:success] = "Question is deleted!"
		redirect_to root_path
	end

	private

		def question_params
			params.require(:question).permit(:title, :body)
		end

		def must_be_logged_in
			unless user_signed_in?
				flash[:danger] = "You need to log in to ask questions."
				redirect_to root_path
			end
		end
end

class QuestionsController < ApplicationController
	before_action :authenticate_user!, except: [ :index, :show ]
	before_action :find_question_for_current_user, only: [ :edit, :update, :destroy ]

	def index
		@questions = Question.all.order("created_at DESC")
	end

	def new
		@question = Question.new
	end

	def show
		@question = Question.find(params[:id])
		@answers = @question.answers.order('best DESC, created_at')
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
	end

	def update
		if @question.update(question_params)
			flash[:success] = "Question updated!"
			redirect_to @question
		else
			render "edit"
		end
	end

	def destroy
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

		def find_question_for_current_user
			@question = Question.find(params[:id])
		end
end

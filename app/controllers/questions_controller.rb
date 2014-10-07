class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :find_question, only: [:show, :edit, :update, :destroy]
  before_action :question_belongs_to_current_user?, only: [:edit, :update, :destroy]
  
  respond_to :json, only: [:update]

  def index
    @questions = Question.all.order("created_at DESC")
  end

  def new
    @question = Question.new
    @attachment = @question.attachments.build
  end

  def show
    @answers = @question.answers.order('best DESC, created_at')
    @comments = @question.comments.order('created_at')
    @comment = Comment.new
    @answer = Answer.new
    @attachment = @answer.attachments.build
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

  def update
    if @question.update(question_params)
      flash.now[:success] = "Question updated!"
      render json: @question, root: false
    else
      flash.now[:danger] = "Question is not updated! See errors below."
      render json: @question.errors.as_json, status: :unprocessable_entity
    end
  end

  def destroy
    @question.destroy
    flash[:success] = "Question is deleted!"
    redirect_to root_path
  end

  private

    def question_params
      params.require(:question).permit(:title, :body, :tag_list, attachments_attributes: [:file])
    end

    def find_question
      @question = Question.find(params[:id])
    end

    def question_belongs_to_current_user?
      unless @question.user == current_user
        redirect_to root_path
      end
    end
end

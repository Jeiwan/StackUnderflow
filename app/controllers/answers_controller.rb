class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :find_question, only: [:create]
  before_action :find_answer, only: [:edit, :update, :destroy, :mark_best]
  before_action :answer_belongs_to_current_user?, only: [:edit, :update, :destroy]
  before_action :question_belongs_to_current_user?, only: [:mark_best]

  def create
    @answer = @question.answers.new(answer_params)
    @comment = Comment.new

    if @answer.save
      current_user.answers << @answer
      flash.now[:success] = "Answer is created!"
    else
      flash.now[:danger] = "Answer is not created! See errors below."
    end
  end

  def edit
  end

  def update
    if @answer.update(answer_params)
      flash[:success] = "Answer is updated!"
      redirect_to question_path(@answer.question)
    else
      render "edit"
    end
  end

  def destroy
    @question = @answer.question
    @answer_id = @answer.id
    @answer.destroy
    flash.now[:success] = "Answer is deleted!"
  end

  def mark_best
    @answer.mark_best!
    flash[:success] = "Answer marked as best!"
    redirect_to @answer.question
  end

  private
    
    def answer_params
      params.require(:answer).permit(:body)
    end

    def find_answer
      @answer = Answer.find(params[:id])
    end

    def find_question
      @question = Question.find(params[:question_id])
    end

    def answer_belongs_to_current_user?
      unless @answer.user == current_user
        redirect_to root_path
      end
    end

    def question_belongs_to_current_user?
      unless @answer.question.user == current_user
        redirect_to @answer.question
      end
    end
end

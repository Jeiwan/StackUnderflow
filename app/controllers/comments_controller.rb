class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_commentable
  before_action :find_comment, only: [:edit, :update, :destroy]
  before_action :comment_belongs_to_current_user?, only: [:edit, :update, :destroy]
  
  def create
    @comment = @commentable.comments.new(comment_params)

    if @comment.save
      current_user.comments << @comment
      flash.now[:success] = "Comment is created!"
    else
      flash.now[:danger] = "Invalid data! Comment length should be more than 10 symbols!"
    end
  end

  def edit
  end

  def update
    if @comment.update(comment_params)
      flash.now[:success] = "Comment is edited!"
    else
      flash.now[:danger] = "Comment is not edited! See errors below."
    end
  end

  def destroy
    @comment.destroy
    flash.now[:success] = "Comment is deleted!"
  end

  private
    def comment_params
      params.require(:comment).permit(:body)
    end

    def find_commentable
      if !params[:answer_id].nil?
        @commentable = Answer.find(params[:answer_id])
        @return_path = @commentable.question
      elsif !params[:question_id].nil?
        @commentable = Question.find(params[:question_id])
        @return_path = @commentable
      end
    end

    def find_comment
      @comment = @commentable.comments.find(params[:id])
    end

    def comment_belongs_to_current_user?
      unless @comment.user == current_user
        redirect_to root_path, status: 403
      end
    end
end

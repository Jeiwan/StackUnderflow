class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_commentable
  before_action :find_comment, only: [:edit, :update, :destroy]
  before_action :comment_belongs_to_current_user?, only: [:edit, :update, :destroy]

  respond_to :json, only: [:create, :update, :destroy]
  
  def create
    @comment = @commentable.comments.new(comment_params)

    if @comment.save
      current_user.comments << @comment
      flash.now[:success] = "Comment is created!"
      respond_with @comment, location: nil, root: false
    else
      flash.now[:danger] = "Invalid data! Comment length should be more than 10 symbols!"
      respond_with(@comment.errors.as_json, status: :unprocessable_entity, location: nil)
    end
  end

  def update
    if @comment.update(comment_params)
      flash.now[:success] = "Comment is edited!"
      render json: @comment, root: false
    else
      flash.now[:danger] = "Comment is not edited! See errors below."
      render json: @comment.errors.as_json, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    flash.now[:success] = "Comment is deleted!"
    respond_with :nothing, status: 204
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

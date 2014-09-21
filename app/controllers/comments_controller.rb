class CommentsController < ApplicationController
  before_action :authenticate_user!
  
  def create
    @question = Question.find(params[:question_id])
    @comment = question.commentable.new(comment_params)

    if @comment.save
      flash[:success] = "Comment is created!"
    else
      flash[:danger] = "Comment is not created!"
    end
    redirect question_path(@question)
  end

  private
    def comment_params
      params.require(:comment).permit(:body)
    end
end

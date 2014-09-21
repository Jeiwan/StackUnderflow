class CommentsController < ApplicationController
  before_action :authenticate_user!
  
  def create
    @question = Question.find(params[:question_id])
    @comment = @question.comments.new(comment_params)

    if @comment.save
      current_user.comments << @comment
      flash[:success] = "Comment is created!"
    else
      flash[:danger] = "Ivalid data! Comment length should be more than 10 symbols!"
    end
    redirect_to question_path(@question)
  end

  private
    def comment_params
      params.require(:comment).permit(:body)
    end
end

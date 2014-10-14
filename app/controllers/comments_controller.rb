class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_parent
  before_action :find_comment, only: [:edit, :update, :destroy]
  before_action :comment_belongs_to_current_user?, only: [:edit, :update, :destroy]
  after_action :publish_after_destroy, only: [:destroy]

  def create
    @comment = @parent.comments.new(comment_params)

    if @comment.save
      current_user.comments << @comment
      flash.now[:success] = "Comment is created!"
      PrivatePub.publish_to "/questions/#{@parent.class.name == 'Question' ? @parent.id : @parent.question.id}", comment_create: CommentSerializer.new(@comment, root: false).to_json, parent: @parent.class.name, parent_id: @parent.id
      render json: @comment, status: 201, root: false
    else
      flash.now[:danger] = "Invalid data! Comment length should be more than 10 symbols!"
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  def update
    update_resource @comment
  end

  def destroy
    destroy_resource @comment
  end

  private
    def comment_params
      params.require(:comment).permit(:body)
    end

    def find_comment
      @comment = Comment.find(params[:id])
    end

    def comment_belongs_to_current_user?
      unless @comment.user == current_user
        redirect_to root_path, status: 403
      end
    end

    def publish_after_destroy
      PrivatePub.publish_to "/questions/#{@comment.commentable.class.name == 'Question' ? @comment.commentable.id : @comment.commentable.question.id}", comment_destroy: @comment.id, parent: @comment.commentable.class.name, parent_id: @comment.commentable.id
    end
end

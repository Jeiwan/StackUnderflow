class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_parent
  before_action :find_comment, only: [:edit, :update, :destroy]
  after_action :publish, only: [:create, :destroy], unless: -> { Rails.env.production? }

  respond_to :json

  authorize_resource

  def create
    respond_with @comment = @parent.comments.create(comment_params.merge(user_id: current_user.id))
  end

  def update
    update_resource @comment
  end

  def destroy
    respond_with @comment.destroy
  end

  private
    def comment_params
      params.require(:comment).permit(:body)
    end

    def find_comment
      @comment = Comment.find(params[:id])
    end

    def publish
      case params[:action]
      when "create"
        channel_params = {comment_create: CommentSerializer.new(@comment, root: false).to_json, parent: @parent.class.name, parent_id: (@parent.id unless @comment.errors.any?)}
      when "destroy"
        channel_params = {comment_destroy: @comment.id, parent: @comment.commentable.class.name, parent_id: @comment.commentable.id}
      end
      PrivatePub.publish_to "/questions/#{@comment.commentable.class.name == 'Question' ? @comment.commentable.id : @comment.commentable.question.id}", channel_params
    end
end

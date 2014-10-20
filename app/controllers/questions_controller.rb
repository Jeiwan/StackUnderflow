class QuestionsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :new, :update, :destroy]
  before_action :find_question, only: [:show, :edit, :update, :destroy]
  before_action :question_belongs_to_current_user?, only: [:edit, :update, :destroy]
  before_action :add_user_id_to_attachments, only: [:create, :update]

  respond_to :html, except: [:update]
  respond_to :json, only: [:update]
  
  def index
    respond_with @questions = Question.all
  end

  def new
    @question = Question.new
    @attachment = @question.attachments.build
  end

  def show
    @answers = @question.answers.order('best, created_at DESC')
    @comments = @question.comments.order('created_at')
    @comment = Comment.new
    @answer = Answer.new
    @question.impressions.find_or_create_by(remote_ip: request.remote_ip, user_agent: (request.user_agent || "no user_agent"))
  end

  def create
    respond_with @question = current_user.questions.create(question_params)
  end

  def update
    update_resource @question
  end

  def destroy
    respond_with @question.destroy
  end

  def show_by_tag
    @questions = Question.where_tag(params[:tag_name])
    render "index"
  end

  def sort_by_votes
    @questions = Question.by_votes
    render "index"
  end

  def unanswered
    @questions = Question.unanswered
    render "index"
  end

  private

    def question_params
      params.require(:question).permit(:title, :body, :tag_list, attachments_attributes: [:file, :file_cache, :user_id, :_destroy])
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

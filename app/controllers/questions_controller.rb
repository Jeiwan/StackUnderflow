class QuestionsController < ApplicationController
  before_action :authenticate_user!, only: [:create, :new, :update, :destroy]
  before_action :find_question, only: [:show, :edit, :update, :destroy]
  before_action :add_user_id_to_attachments, only: [:create, :update]

  respond_to :html, except: [:update]
  respond_to :json, only: [:update]

  authorize_resource
  
  def index
    respond_with @questions = Question.page(params[:page])
  end

  def popular
    @questions = Question.popular.page(params[:page])
    render :index
  end

  def unanswered
    @questions = Question.unanswered.page(params[:page])
    render :index
  end

  def active
    @questions = Question.active.page(params[:page])
    render :index
  end

  def tagged
    @questions = Question.tagged(params[:tag]).page(params[:page])
    render :index
  end

  def new
    @question = Question.new
    @attachment = @question.attachments.build
  end

  def show
    @answers = @question.answers
    @comments = @question.comments
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

  private

    def question_params
      params.require(:question).permit(:title, :body, :tag_list, attachments_attributes: [:file, :file_cache, :user_id, :_destroy])
    end

    def find_question
      @question = Question.find(params[:id])
    end
end

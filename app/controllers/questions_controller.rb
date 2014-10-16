class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show, :show_by_tag]
  before_action :find_question, only: [:show, :edit, :update, :destroy]
  before_action :question_belongs_to_current_user?, only: [:edit, :update, :destroy]
  before_action :add_user_id_to_attachments, only: [:create, :update]
  
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
    update_resource @question
  end

  def destroy
    @question.destroy
    flash[:success] = "Question is deleted!"
    redirect_to root_path
  end

  def show_by_tag
    @questions = Question.where_tag(params[:tag_name])
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

    def add_user_id_to_attachments
      if params[:question][:attachments_attributes]
        params[:question][:attachments_attributes].each do |k, v|
          v[:user_id] = current_user.id
        end
      end
    end
end

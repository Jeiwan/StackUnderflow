class Api::V1::QuestionsController < Api::V1::BaseController
  authorize_resource

  def index
    respond_with @questions = Question.all
  end

  def show
    respond_with @question = Question.find(params[:id]), serializer: QuestionShowSerializer
  end
end

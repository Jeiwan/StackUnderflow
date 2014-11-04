class Api::V1::AnswersController < Api::V1::BaseController
  authorize_resource

  def index
    @question = Question.find(params[:question_id])
    respond_with @answers = @question.answers, each_serializer: AnswerIndexSerializer
  end

  def show
    respond_with @answer = Answer.find(params[:id])
  end
end

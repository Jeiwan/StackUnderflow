class Api::V1::AnswersController < Api::V1::BaseController
  authorize_resource

  def index
    @question = Question.find(params[:question_id])
    respond_with @answers = @question.answers
  end

  def show
    respond_with @answer = Answer.find(params[:id])
  end

  def create
    @question = Question.find(params[:question_id])
    respond_with @answer = @question.answers.create(answer_params.merge(user_id: current_resource_owner.id))
  end

  private
    def answer_params
      params.require(:answer).permit(:body)
    end
end

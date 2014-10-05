class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :answers

  def answers
    object.answers.each { |answer| { id: answer.id, body: answer.body, author: answer.user.username } }
  end
end

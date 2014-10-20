class QuestionSerializer < ApplicationSerializer
  attributes :id, :title, :body, :answers, :files, :tags, :list_of_tags, :has_best_answer

  def answers
    object.answers.each { |answer| { id: answer.id, body: answer.body, author: answer.user.username } }
  end

  def tags
    object.tags.map { |t| t.name  }
  end

  def list_of_tags
    object.tags.map(&:name).join(",")
  end

  def has_best_answer
    object.has_best_answer?
  end
end

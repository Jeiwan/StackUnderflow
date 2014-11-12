class AnswerSerializer < ApplicationSerializer
  include ActionView::Helpers::DateHelper

  attributes :id, :body, :created, :question, :edited, :files, :is_best, :votes_sum, :author
  has_one :user
  has_many :comments

  def created
    time_ago_in_words(object.created_at)
  end

  def question
    question = object.question
    {id: question.id, title: question.title, body: question.body, has_best_answer: question.has_best_answer?}
  end

  def edited
    object.updated_at.to_s > object.created_at.to_s ? time_ago_in_words(object.updated_at) : false
  end

  def is_best
    object.best?
  end

  def author
    object.user.username
  end

  def files
    object.attachments.map { |a| {id: a.id, path: a.file.url, filename: a.file.file.filename} }
  end
end

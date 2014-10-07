class AnswerSerializer < ActiveModel::Serializer
  include ActionView::Helpers::DateHelper

  attributes :id, :body, :created, :question, :comments, :edited, :attachments, :is_best
  has_one :user

  def created
    time_ago_in_words(object.created_at)
  end

  def question
    question = object.question
    {id: question.id, title: question.title, body: question.body}
  end

  def comments
    if object.comments.any?
      object.comments.map { |comment| { id: comment.id, body: comment.body } }
    else
      false
    end
  end

  def edited
    object.updated_at.to_s > object.created_at.to_s ? time_ago_in_words(object.updated_at) : false
  end

  def attachments
    if object.attachments.any?
      object.attachments.map { |attachment| { file: File.basename(attachment.file.url), url: attachment.file.url } }
    else
      false
    end
  end

  def is_best
    object.best?
  end
end

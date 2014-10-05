class AnswerSerializer < ActiveModel::Serializer
  attributes :id, :body, :created, :question, :comments, :edited, :attachments, :is_best
  has_one :user

  def created
    object.created_at.strftime("%d/%m/%Y, %R")
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
    object.updated_at.to_s > object.created_at.to_s ? object.updated_at.strftime("%d/%m/%Y, %R") : false
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

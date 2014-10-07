class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :title, :body, :answers, :files, :tags, :list_of_tags

  def answers
    object.answers.each { |answer| { id: answer.id, body: answer.body, author: answer.user.username } }
  end

  def files
    object.attachments.map { |a| {path: a.file.file, filename: a.file.file.filename}  }
  end

  def tags
    object.tags.map { |t| t.name  }
  end

  def list_of_tags
    object.tags.map(&:name).join(",")
  end
end

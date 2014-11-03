class QuestionSerializer < ApplicationSerializer
  attributes :id, :title, :body, :files, :tags_array, :list_of_tags, :has_best_answer, :votes_sum

  has_many :answers
  has_many :comments

  def tags_array
    object.tags.map { |t| t.name  }
  end

  def list_of_tags
    object.tag_list
  end

  def has_best_answer
    object.has_best_answer?
  end

  def files
    object.attachments.map { |a| {path: a.file.url, filename: a.file.file.filename} }
  end
end

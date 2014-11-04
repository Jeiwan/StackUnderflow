class AnswerIndexSerializer < ApplicationSerializer
  include ActionView::Helpers::DateHelper

  attributes :id, :body, :created, :edited, :files, :is_best, :votes_sum, :author

  def created
    time_ago_in_words(object.created_at)
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
end

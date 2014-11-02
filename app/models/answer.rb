class Answer < ActiveRecord::Base
  include Votable

  default_scope { order("best DESC, created_at DESC") }

  belongs_to :question, counter_cache: true
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  accepts_nested_attributes_for :attachments, reject_if: proc { |attrs| attrs['file'].blank? && attrs['file_cache'].blank? }

  after_save :update_question_activity

  validates :body, presence: true, length: { in: 10..5000 }

  def mark_best!
    unless question.has_best_answer?
      update(best: true)
      user.increment(:reputation, 15).save!
    end
  end

  private

    def update_question_activity
      question.save
    end
end

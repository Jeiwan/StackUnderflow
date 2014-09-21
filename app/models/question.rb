class Question < ActiveRecord::Base
  has_many :answers
  belongs_to :user
  has_many :comments, as: :commentable

  validates :body, presence: true, length: { in: 10..5000 }
  validates :title, presence: true, length: { in: 5..512 }

  def has_best_answer?
    answers.find_by(best: true) ? true : false
  end
end

class Answer < ActiveRecord::Base

  belongs_to :question
  belongs_to :user
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :votes, as: :votable, dependent: :destroy
  accepts_nested_attributes_for :attachments

  validates :body, presence: true, length: { in: 10..5000 }

  def mark_best!
    update(best: true) unless question.has_best_answer?
  end

  def vote_up(user)
    unless voted_by? user
      votes.create(user_id: user.id, vote: 1)
    end
  end

  def vote_down(user)
    unless voted_by? user
      votes.create(user_id: user.id, vote: -1)
    end
  end

  def total_votes
    votes.inject(0) { |s, v| s + v.vote }
  end

  def voted_by?(user)
    votes.find_by_user_id(user) ? true : false
  end
end

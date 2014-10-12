module Votable
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :votable, dependent: :destroy
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
    votes.sum(:vote)
  end

  def voted_by?(user)
    votes.find_by_user_id(user) ? true : false
  end
end

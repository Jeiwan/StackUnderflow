module Votable
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :votable, dependent: :destroy
  end

  def vote_up(voter)
    unless voted_by? voter
      votes.create(user_id: voter.id, vote: 1)

      if self.class.name == 'Question'
        Reputation.add_to(user, :question_vote_up)
      elsif self.class.name == 'Answer'
        Reputation.add_to(user, :answer_vote_up)
      end
    end
  end

  def vote_down(voter)
    unless voted_by? voter
      votes.create(user_id: voter.id, vote: -1)
    end
  end

  def voted_by?(voter)
    votes.find_by_user_id(voter) ? true : false
  end

  def user_voted(voter)
    if voted_by?(voter)
      votes.find_by_user_id(voter).vote
    end
  end
end

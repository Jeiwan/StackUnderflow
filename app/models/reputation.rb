class Reputation < ActiveRecord::Base
  belongs_to :user

  def self.add_to(to_user, operation)
    values = {question_vote_up: 5, answer_vote_up: 10, answer_mark_best: 15}

    if to_user && operation && values[operation]
      to_user.reputations.create(value: values[operation]) 
      to_user.increment(:reputation_sum, values[operation]).save!
    end
  end
end

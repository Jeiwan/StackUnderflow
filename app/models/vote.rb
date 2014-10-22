class Vote < ActiveRecord::Base

  belongs_to :votable, polymorphic: true
  belongs_to :user

  after_save :increment_parent_counter
  after_destroy :decrement_parent_counter

  validates :user_id, presence: true
  validates :vote, presence: true
  validates :votable_id, presence: true
  validates :votable_type, presence: true

  private

    def increment_parent_counter
      votable.increment(:votes_sum, vote).save
    end

    def decrement_parent_counter
      votable.decrement(:votes_sum, vote).save
    end
end

class Vote < ActiveRecord::Base

  belongs_to :votable, polymorphic: true
  belongs_to :user

  validates :user_id, presence: true
  validates :vote, presence: true
  validates :votable_id, presence: true
  validates :votable_type, presence: true

end

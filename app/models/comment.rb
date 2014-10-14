class Comment < ActiveRecord::Base
  include Votable

  belongs_to :user
  belongs_to :commentable, polymorphic: true

  validates :body, presence: true, length: { in: 10..5000 }
end

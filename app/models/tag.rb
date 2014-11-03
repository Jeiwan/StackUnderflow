class Tag < ActiveRecord::Base

  default_scope -> { alphabetical }
  scope :popular, -> { unscoped.order("questions_count DESC, created_at DESC") }
  scope :alphabetical, -> { unscoped.order("name ASC") }
  scope :newest, -> { unscoped.order("created_at DESC") }

  has_many :taggings
  has_many :questions, through: :taggings

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { in: 1..24 }
end

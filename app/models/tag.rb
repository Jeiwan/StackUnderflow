class Tag < ActiveRecord::Base

  default_scope -> { alphabetical }

  has_many :questions, through: :taggings
  has_many :taggings

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { in: 1..24 }

  scope :alphabetical, -> { unscoped.order("name ASC") }
  scope :newest, -> { unscoped.order("created_at DESC") }
  scope :popular, -> { unscoped.order("questions_count DESC, created_at DESC") }

  paginates_per 28
end

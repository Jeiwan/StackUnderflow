class Tag < ActiveRecord::Base

  default_scope -> { alphabetical }
  scope :popular, -> { unscoped.joins(:questions).group("tags.id").order("count(questions_tags.question_id) DESC, tags.created_at DESC") }
  scope :alphabetical, -> { unscoped.order("name ASC") }
  scope :newest, -> { unscoped.order("created_at DESC") }

  has_and_belongs_to_many :questions

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { in: 1..24 }, format: { with: /\A[a-zA-Z][\w#\+\-\.]*\z/, message: "can include only: latin letters, digits, ., +, -, _, and #. Every tag must begin with a letter." }
end

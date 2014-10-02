class Tag < ActiveRecord::Base
  has_and_belongs_to_many :questions

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { in: 1..24 }, format: { with: /\A[a-zA-Z][\w#\+\-\.]*\z/, message: "can contain only letters, digits, ., +, -, _, and #. It must begin with a letter." }

  def self.create_from_list(tags)
    tags.map { |tag| self.find_by_name(tag) || self.create(name: tag) }
  end
end

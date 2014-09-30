class Tag < ActiveRecord::Base
  has_and_belongs_to_many :questions

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { in: 1..24 }, format: { with: /\A[a-zA-Z][\w_\.-]*[a-zA-Z0-9#\+]+\z/, message: "can contain only letters, digits, ., +, -, _, and #. It must begin with a letter." }
end

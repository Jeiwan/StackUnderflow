class Question < ActiveRecord::Base
	has_many :answers
	belongs_to :user

	validates :body, presence: true, length: { in: 10..5000 }
	validates :title, presence: true, length: { in: 5..512 }

end

class Question < ActiveRecord::Base
	has_many :answers
	belongs_to :user

	validates_presence_of :title, :body
	validates :body, length: { in: 10..5000 }
	validates :title, length: { in: 5..512 }
end

class Question < ActiveRecord::Base
	has_many :answers

	validates_presence_of :title, :body
	validates :body, length: { minimum: 10 }
	validates :title, length: { minimum: 5 }
end

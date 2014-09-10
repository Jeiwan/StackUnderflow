class Answer < ActiveRecord::Base
	belongs_to :question

	validates_presence_of :body
	validates :body, length: { minimum: 10 }
end

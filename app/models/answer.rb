class Answer < ActiveRecord::Base
	belongs_to :question
	belongs_to :user

	validates_presence_of :body
	validates :body, length: { in: 10..5000 }

	def mark_best!
		update(best: true)
	end

	def unmark_best!
		update(best: false)
	end
end

class Answer < ActiveRecord::Base
	belongs_to :question
	belongs_to :user

	validates :body, presence: true, length: { in: 10..5000 }

	def mark_best!
		update(best: true)
	end
end

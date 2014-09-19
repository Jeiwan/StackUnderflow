require 'rails_helper'

feature "Select Best Answer" do
	given(:user) { create(:user) }
	given(:question) { create(:question, user: user) }
	given(:another_user) { create(:user) }
	given(:answer) { create(:answer, question: question, user: another_user) } 

	scenario "User selects a best answer of his question" do
		sign_in user

		expect(question.answers).to include answer

		visit question_path(question)
		click_link "mark-best-answer"

		expect(page).to have_selector ".best-answer"
	end
end

require 'rails_helper'

feature "Edit Answer" do

	given(:user) { create(:user) }
	given(:question) { create(:question, user: user) }
	given(:answer) { create(:answer, user: user, question: question) }

	scenario "User edits his answer" do
		sign_in user

		expect(question.answers).to include answer

		visit question_path(question)
		click_link "edit-answer"

		expect(page).to have_content answer.body

		fill_in "answer_body", with: answer.body.reverse
		click_button "Edit"

		expect(page).to have_content answer.body.reverse
	end
end

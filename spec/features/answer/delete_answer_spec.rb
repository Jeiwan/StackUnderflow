require 'rails_helper'

feature "Delete Answer" do

	given(:user) { create(:user) }
	given(:question) { create(:question, user: user) }
	given(:answer) { create(:answer, user: user, question: question) }

	scenario "User deletes his anwer" do
		sign_in user

		expect(question.answers).to include answer

		visit question_path(question)
		click_link "delete-answer"

		expect(page).to have_selector ".alert-success"
		expect(page).not_to have_content answer.body
	end
end

require 'rails_helper'

feature "Answer a Question", %q{
	In order to help other people
	As an authenticated user with a lot of spare time
	I want to have an ability to answer other users' questions, edit, and delete my answers
} do

	given(:inquirer) { create(:user) }
	given(:question) { create(:question, user: inquirer) }
	given(:answerer) { create(:user) }
	given(:answer) { build(:answer, question: question, user: answerer) }

	scenario "Authenticated user answers another user's question" do
		sign_in answerer

		visit question_path(question)
		fill_in :answer_body, with: answer.body
		click_on "Answer"
		
		expect(page).to have_content answer.body
		expect(page).to have_content answer.user.username
	end

	scenario "Authenticated user answers another user's question without filling a required field" do
		sign_in answerer
		visit question_path(question)
		click_on "Answer"

		expect(page).to have_selector ".alert-danger"
	end

end

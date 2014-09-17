require 'rails_helper'
include FeatureMacros

feature "Answer a Question", %q{
	In order help other people
	As an authenticated user with a lot of spare time
	I want to have an ability to answer other user's questions
} do

	given(:inquirer) { create(:user) }
	given(:question) { create(:question, user: inquirer) }
	given(:answerer) { create(:user) }
	given(:answer) { build(:answer, question: question, user: answerer) }

	scenario "Authenticated user answers another user's question" do
		sign_in answerer

		visit question_path(question)
		#save_and_open_page
		fill_in :answer_body, with: answer.body
		click_on "Answer"
		
		expect(page).to have_content answer.body
		expect(page).to have_content answer.user.username
	end

end

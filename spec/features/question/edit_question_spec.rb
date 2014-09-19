require 'rails_helper'

feature "Edit Question" do

	given(:user) { create(:user) }
	given(:question) { create(:question, user: user) }

	scenario "User edits his question" do
		sign_in user

		visit question_path(question)

		click_link "edit-question"

		expect(page).to have_content "Body"

		fill_in "Body", with: question.body.reverse
		click_on "Edit"

		expect(page).to have_content question.body.reverse

	end

end

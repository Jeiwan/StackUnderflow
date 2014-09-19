require 'rails_helper'

feature "Delete Question" do

	given(:user) { create(:user) }
	given(:question) { create(:question, user: user) }

	scenario "User deletes his questions" do
		sign_in user

		visit question_path(question)
		click_on "delete-question"
		#page.driver.browser.switch_to.alert.accept

		expect(page).to have_selector ".alert-success"
		expect(page).not_to have_content question.body
	end
end

require 'rails_helper'

feature "Ask Question", %q{
	In order to resolve a problem
	As a registered and authenticated user
	I want to have an ability to ask question
} do

	given(:user) { create(:user) }
	given(:question) { build(:question) }

	scenario "Authenticated user asks a question" do


		visit root_path
		click_on "Log in"
		fill_in "Email", with: user.email
		fill_in "Password", with: user.password
		click_button "Log in"

		click_on "Ask a Question"

		fill_in "Title", with: question.title
		fill_in "Body", with: question.body
		click_on "Ask"

		expect(page).to have_content question.title
		expect(page).to have_content question.body

	end
	
end

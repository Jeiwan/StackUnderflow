require 'rails_helper'

feature "Singin Up", %q{
	In order to ask a question
	As a non-registered user
	I want to have an ability to sign up and sign in
} do

	given(:user) { build(:user) }

	scenario "Non-registered user signs up" do

		visit root_path
		click_on "Sign up"
		fill_in "Username", with: user.username
		fill_in "Email", with: user.email
		fill_in "Password", with: user.password
		fill_in "Password confirmation", with: user.password_confirmation
		click_button "Sign up"

		expect(page).to have_content "successfully"

	end

	scenario "Registered user signs in" do

		user.save

		visit root_path

		click_on "Log in"
		fill_in "Email", with: user.email
		fill_in "Password", with: user.password
		click_button "Log in"

		expect(page).to have_content "successfully"

	end

end

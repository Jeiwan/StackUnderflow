require 'rails_helper'

feature "Sign up", %q{
	In order to ask and answer questions
	As a non-registered user
	I want to have an ability to sign up
} do

	given(:user) { build(:user) }

	scenario "Non-registered user signs up" do
		visit new_user_registration_path

		fill_in "Username", with: user.username
		fill_in "Email", with: user.email
		fill_in "Password", with: user.password
		fill_in "Password confirmation", with: user.password_confirmation
		click_button "Sign up"

		expect(page).to have_content user.username
	end

end

require 'rails_helper'

feature "Sign in", %q{
	In order to ask and answer questions
	As a registered user
	I want to have an ability to sign in
} do

	given(:user) { create(:user) }

	scenario "Registered user signs in" do
		visit new_user_session_path

		fill_in "Email", with: user.email
		fill_in "Password", with: user.password
		click_button "Log in"

		expect(page).to have_content user.username
	end

end

require 'rails_helper'

feature "Sign in", %q{
	In order to ask and answer questions
	As a registered user
	I want to have an ability to sign in
} do

	given(:user) { create(:user) }

	scenario "Registered user signs in" do
		sign_in user.email, user.password
		expect(page).to have_content user.username
	end

	scenario "Registered user signs in with wrong email" do
		sign_in user.email.reverse, user.password
		expect(page).to have_content "Invalid email address or password"
	end

	scenario "Registered user signs in with wrong password" do
		sign_in user.email, user.password.reverse
		expect(page).to have_content "Invalid email or password"
	end
end

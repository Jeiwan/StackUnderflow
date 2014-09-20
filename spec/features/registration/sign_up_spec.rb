require 'rails_helper'

feature "Sign up", %q{
	In order to ask and answer questions
	As a non-registered user
	I want to have an ability to sign up
} do

	given(:user) { build(:user) }

	scenario "Non-registered user signs up" do
		sign_up_with user.username, user.email, user.password
		expect(page).to have_content user.username
	end

	scenario "Non-registered user signs up not filling required fields" do
		sign_up_with "", "", ""
		expect(page).to have_content "errors"
	end

	scenario "Non-registered user signs up with already taken email and username" do
		user.save!
		sign_up_with user.username, user.email, user.password
		expect(page).to have_content "Email has already been taken"
		expect(page).to have_content "Username has already been taken"
	end
end

def sign_up_with username, email, password
	visit new_user_registration_path
	fill_in "Username", with: username
	fill_in "Email", with: email
	fill_in "Password", with: password
	fill_in "Password confirmation", with: password
	click_button "Sign up"
end

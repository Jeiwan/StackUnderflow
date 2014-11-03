require_relative "../features_helper"

feature "Sign up", %q{
  In order to ask and answer questions
  As a non-registered user
  I want to have an ability to sign up
} do

  given(:user) { build(:user) }
  given(:user2) { create(:user) }

  background do
    ActionMailer::Base.deliveries.clear
  end

  scenario "Non-registered user signs up" do
    sign_up_with user.username, user.email, user.password

    expect(page).to have_content "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."
    expect(ActionMailer::Base.deliveries.count).to eq 1
    last_email = ActionMailer::Base.deliveries.last
    confirmation_link = /<a href="(.+)">Confirm my account<\/a>/.match(last_email.body.to_s)[1]
    visit confirmation_link
    expect(page).to have_content "successfully confirmed"
    sign_in user.email, user.password

    expect(page).to have_content user.username
  end

  scenario "Non-registered user signs up without filling required fields" do
    sign_up_with "", "", ""
    expect(page).to have_content "errors"
  end

  scenario "Non-registered user signs up with already taken email and username" do
    user.save!
    sign_up_with user.username, user.email, user.password
    expect(page).to have_content "Email has already been taken"
    expect(page).to have_content "Username has already been taken"
  end

  scenario "Guest user signs up via OAuth, provides email, and confirms it." do
    set_facebook_account

    visit new_user_registration_path
    click_link "Sign in with Facebook"
    expect(page).to have_content "Signed in as"
    expect(page).to have_content "Your account is restricted. Please, provide your email address on 'Edit profile' page."

    user = User.last
    visit edit_user_path(user)
    fill_in "Email", with: "real@email.truly"
    click_button "Update User"

    expect(page).to have_content "We sent a confirmation email on #{user.reload.unconfirmed_email}. Please, click 'Confirm my account' link in the email or provide other address below."

    expect(ActionMailer::Base.deliveries.count).to eq 1
    last_email = ActionMailer::Base.deliveries.last
    confirmation_link = /<a href="(.+)">Confirm my account<\/a>/.match(last_email.body.to_s)[1]
    visit confirmation_link
    expect(page).to have_content "successfully confirmed"
    click_link "Sign in with Facebook"
    expect(page).to have_content "Signed in as"
  end

  scenario "Guest user signs up via OAuth and provides an already taken email" do
    set_facebook_account
    user.save
    visit new_user_registration_path
    click_link "Sign in with Facebook"

    user = User.last
    visit edit_user_path(user)
    fill_in "Email", with: user2.email
    click_button "Update User"

    expect(page).to have_content "Unable"
    expect(page).to have_content "taken"
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

def set_facebook_account
  auth = {provider: "facebook", uid: "1234567890"}
  OmniAuth.config.test_mode = true
  OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
    provider: auth[:provider],
    uid: auth[:uid]
  })
end

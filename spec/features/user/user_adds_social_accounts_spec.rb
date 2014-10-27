require_relative "../features_helper"

feature "User Adds Other Accounts in Social Networks" do

  given!(:user) { create :user }
  given(:identity) { create :identity, provider: "twitter", uid: "12345", user: user }

  background { sign_in user }

  scenario "User visits 'My logins' in his profile" do
    visit user_path(user)

    expect(page).to have_link 'my logins'
    click_link 'my logins'
    expect(page.current_path).to match /\/users\/#{user.username}\/logins\z/
    expect(page).to have_link "Add Facebook account"
    expect(page).to have_link "Add Twitter account"
    expect(page).to have_link "Add Vkontakte account"
    expect(page).to have_link "Add Github account"
  end

  scenario "User cannot add an account that he already connected" do
    identity.save
    visit logins_user_path(user)

    expect(page).not_to have_link "Add Twitter account"
    expect(page).to have_content "Twitter account already added"
  end

  scenario "User connects an account" do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
      provider: "facebook",
      uid: "1234567890"
    })
    visit logins_user_path(user)

    click_link "Add Facebook account"
    expect(page.current_path).to match /\/users\/#{user.username}\/logins\z/
    expect(page).to have_content "Facebook account already added"
  end
end

require_relative "../features_helper"

feature "Registered User Has Profile" do

  given!(:user) { create(:user) }

  background { sign_in user }

  scenario "User can visit his profile" do
    visit user_path(user.username)

    expect(page).to have_content user.username
    expect(page).to have_selector "img.user-avatar[src='#{user.avatar.url}']"
  end

end

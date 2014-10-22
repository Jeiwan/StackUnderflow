require_relative "../features_helper"

feature "Users Can Change Avatars" do

  given(:user) { create(:user) }
  given(:other_user) { create(:user) }

  background do
    sign_in user
  end

  scenario "User visits his profile page and changes avatar", js: true do
    visit user_path(user.username)

    expect(page).to have_link "change avatar"
    #click_link "change avatar"
    within(".user-info") do
      page.execute_script("$('form.edit_user').show()");
      attach_file("user_avatar", "#{Rails.root}/spec/features/user/new_avatar.jpg")
      expect(page).to have_selector "img.user-avatar[src$='new_avatar.jpg']"
    end
  end

  scenario "User cannot change other users' avatars" do
    visit user_path(other_user.username)

    expect(page).not_to have_link "change avatar"
    expect(page).not_to have_selector "form.edit_user"
  end

end

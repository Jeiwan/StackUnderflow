require_relative "../features_helper"

feature "User Edits His Profile" do

  given!(:user) { create :user }
  given!(:other_user) { create(:user) }

  background { sign_in user }

  scenario "User visits 'Edit profile' page" do
    visit user_path(user)

    expect(page).to have_link "edit-profile"
    click_link "edit-profile"
    expect(page).to have_content "Edit"
  end

  scenario "User cannot visit other user's 'Edit profile' page" do
    visit user_path(other_user)
    expect(page).not_to have_link "edit-profile"
  end

  scenario "User visits his profile page and changes avatar", js: true do
    visit edit_user_path(user)

    expect(page).to have_link "change avatar"
    within(".user-info") do
      page.execute_script("$('form.change-avatar-form').show()");
      attach_file("user_avatar", "#{Rails.root}/spec/features/user/new_avatar.jpg")
      expect(page).to have_selector "img.user-avatar[src$='new_avatar.jpg']"
    end
  end

  scenario "User edits his username" do
    visit edit_user_path(user)

    fill_in "Username", with: user.username.reverse
    click_button "Update User"

    expect(page.current_path).to match /\/users\/#{user.username.reverse}\z/
    expect(page).to have_content user.username.reverse
  end

  scenario "User cannot take already taken username" do
    visit edit_user_path(user)

    fill_in "Username", with: other_user.username
    click_button "Update User"

    expect(page.current_path).to match /\/users\/#{user.username}\z/
    expect(page).to have_content "problems"
    expect(page).to have_content "has already been taken"
  end

end

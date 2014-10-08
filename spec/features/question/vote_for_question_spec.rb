require_relative "../features_helper.rb"

feature "Vote for question" do

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:question) { create(:question, user: user1) }

  background do
    sign_in user2
    visit question_path(question)
  end

  scenario "User votes for question", js: true do
    within ".question" do
      expect(page).to have_selector ".votes", text: "0"
      find("a.vote-up").click
      expect(page).to have_selector ".votes", text: "1"
    end
  end

  scenario "User votes againt question", js: true do
    within ".question" do
      expect(page).to have_selector ".votes", text: "0"
      find("a.vote-down").click
      expect(page).to have_selector ".votes", text: "-1"
    end
  end

end

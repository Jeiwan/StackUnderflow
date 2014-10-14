require_relative "../features_helper.rb"

feature "Vote for comment" do

  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:question) { create(:question, user: user1) }
  let!(:answer) { create(:answer, user: user1, question: question) }
  let!(:comment1) { create(:answer_comment, user: user1, commentable: answer) }
  let!(:comment2) { create(:answer_comment, user: user2, commentable: answer) }

  background do
    sign_in user2
    visit question_path(question)
  end

  scenario "User votes for comment", js: true do
    within "#comment_#{comment1.id} .voting" do
      expect(page).to have_selector ".votes", text: "0"
      find("a.vote-up").click
      expect(page).to have_selector ".votes", text: "1"
    end
  end

  scenario "User votes againt comment", js: true do
    within "#comment_#{comment1.id} .voting" do
      expect(page).to have_selector ".votes", text: "0"
      find("a.vote-down").click
      expect(page).to have_selector ".votes", text: "-1"
    end
  end

  scenario "User can't vote for his comment" do
    within "#comment_#{comment2.id} .voting" do
      expect(page).not_to have_selector "a.vote-up"
      expect(page).not_to have_selector "a.vote-down"
    end
  end
  
  scenario "User can vote only once", js: true do
    within "#comment_#{comment1.id} .voting" do
      expect(page).to have_selector ".votes", text: "0"
      find("a.vote-down").click
      expect(page).to have_selector ".votes", text: "-1"
      expect(page).not_to have_selector "a.vote-up"
      expect(page).not_to have_selector "a.vote-down"
    end
  end
end

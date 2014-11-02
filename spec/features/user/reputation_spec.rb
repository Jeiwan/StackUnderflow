require_relative "../features_helper"

feature "User Has Reputation" do
  let(:user) { create :user }
  let(:user2) { create :user }
  let(:question) { create :question, user: user }
  let(:answer) { create :answer, user: user }
  let(:comment) { create :answer_comment, user: user }

  background do
    sign_in user
  end

  scenario "New user has 0 reputation" do
    visit user_path(user)
    expect(page).to have_selector ".user-reputation", text: "0"
  end

  scenario "When user's questions is voted the user's reputation increases" do
    question.vote_up(user2)
    visit user_path(user)
    expect(page).to have_selector ".user-reputation", text: "5"
  end

  scenario "When user's answer is voted the user's reputation increases" do
    answer.vote_up(user2)
    visit user_path(user)
    expect(page).to have_selector ".user-reputation", text: "10"
  end

  scenario "When user's answer marked as best their reputation increases" do
    answer.mark_best!
    visit user_path(user)
    expect(page).to have_selector ".user-reputation", text: "15"
  end
end

require_relative "../features_helper"

feature "Delete Answer Comment" do

  given(:user) { create(:user) }
  given(:user2) { create(:user) }
  given(:question) { create(:question, user: user) }
  given!(:answer) { create(:answer, user:user, question: question) }
  given!(:comment) { create(:answer_comment, user: user, commentable: answer) }
  given!(:comment2) { create(:answer_comment, user: user2, commentable: answer) }

  background do
    sign_in user
    visit question_path(question)
  end

  scenario "User deletes his answer comment", js: true do
    within("#answer_#{answer.id} #comment_#{comment.id}") do
      click_on "delete"
    end

    expect(page).not_to have_selector "#comment_#{comment.id}"
  end

  scenario "User can't delete not his answer comment", js: true do
    within("#answer_#{answer.id} #comment_#{comment2.id}") do
      expect(page).not_to have_content "delete"
    end
  end

end

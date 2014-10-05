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
    within(comment_block(answer.id, comment.id)) do
      click_on "delete"
    end

    expect(page).not_to have_selector "#comment_#{comment.id}", text: comment.body
  end

  scenario "User can't delete not his answer comment", js: true do
    within(comment_block(answer.id, comment2.id)) do
      expect(page).not_to have_content "delete"
    end
  end
end

def comment_block(answer_id, comment_id)
  "#answer_#{answer_id} #comment_#{comment_id}"
end

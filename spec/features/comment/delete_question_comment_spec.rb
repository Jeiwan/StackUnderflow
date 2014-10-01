require_relative "../features_helper"

feature "Delete Question Comment" do

  given(:user) { create(:user) }
  given(:user2) { create(:user) }
  given!(:question) { create(:question, user: user, tag_list: "test west best") }
  given!(:comment) { create(:question_comment, user: user, commentable: question) }
  given!(:comment2) { create(:question_comment, user: user2, commentable: question) }

  background do
    sign_in user
    visit question_path(question)
  end

  scenario "User deletes his question comment", js: true do
    within(question_comment(comment.id)) do
      click_on "delete"
    end

    expect(page).not_to have_selector ".question #comment_#{comment.id}", text: comment.body
  end

  scenario "User can't delete not his question comment", js: true do
    within(question_comment(comment2.id)) do
      expect(page).not_to have_content "delete"
    end
  end
end

def question_comment(comment_id)
  ".question #comment_#{comment_id}"
end

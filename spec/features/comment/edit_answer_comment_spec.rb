require_relative "../features_helper"

feature "Edit Question Comment" do

  given(:user) { create(:user) }
  given(:user2) { create(:user) }
  given(:question) { create(:question, user: user) }
  given!(:answer) { create(:answer, question: question, user: user) }
  given!(:comment) { create(:answer_comment, user: user, commentable: answer) }
  given!(:comment2) { create(:answer_comment, user: user2, commentable: answer) }

  background do
    sign_in user
    visit question_path(question)
  end

  scenario "User edits his answer comment", js: true do
    edit_answer_comment answer.id, comment.id, comment.body.reverse

    within("#answer_#{answer.id} .comments") do
      expect(page).to have_content comment.body.reverse
    end
  end

  scenario "User edits his answer comment with valid data", js: true do
    edit_answer_comment answer.id, comment.id, ""

    expect(page).to have_content "problems"
  end

  scenario "User can't edit not his comment", js: true do
    within("#answer_#{answer.id} #comment_#{comment2.id}") do
      expect(page).not_to have_selector "edit"
    end
  end
end

def edit_answer_comment answer_id, comment_id, text
  within("#answer_#{answer_id} #comment_#{comment_id}") do
    click_link "edit"
    expect(page).to have_selector "textarea"
  end

  fill_in "comment_body", with: text
  click_on "Update Comment"
end

require_relative "../features_helper"

feature "Registered User Has Profile" do

  given!(:user) { create(:user) }
  given!(:question) { create(:question, user: user) }
  given!(:answer) { create(:answer, question: question, user: user) }
  given!(:comment) { create(:question_comment, commentable: question, user: user) }

  given(:questions) { create_list(:question, 10, user: user) }
  given(:answers) { create_list(:answer, 10, user: user) }
  given(:comments) { create_list(:question_comment, 10, user: user, commentable: question) }

  background { sign_in user }

  scenario "User can visit his profile" do
    visit user_path(user.username)

    within(".user-info") do
      expect(page).to have_content user.username
      save_and_open_page
      expect(page).to have_selector "img.user-avatar[src='#{user.avatar.small.url}']"
      expect(page).to have_selector ".user-registered", text: user.created_at.strftime("%d/%m/%Y %H:%M")
      expect(page).to have_selector ".user-email", text: user.email
    end

    within(".user-summary") do
      expect(page).to have_selector ".user-questions", text: user.questions.count
      expect(page).to have_selector ".user-answers", text: user.answers.count
      expect(page).to have_selector ".user-comments", text: user.comments.count
      expect(page).to have_content question.title
      expect(page).to have_content answer.body
      expect(page).to have_content comment.body
    end
  end

  scenario "User can see only 5 last questions, answers, and comments in his profile" do
    questions.each { |q| q.save }
    answers.each { |a| a.save }
    comments.each { |c| c.save }
    visit user_path(user.username)

    within(".user-summary") do
      expect(page).to have_selector ".created-questions li", count: 5
      expect(page).to have_selector ".created-answers li", count: 5
      expect(page).to have_selector ".created-comments li", count: 5
    end
  end

  scenario "User can view all his questions on the 'questions' tab in profile" do
    questions.each { |q| q.save }
    visit user_path(user.username)

    expect(page).to have_selector ".user-profile-tabs a", text: "questions"
    within(".user-profile-tabs") do
      click_link "questions"
    end

    within(".user-all-questions") do
      expect(page).to have_content "11 Questions"
      expect(page).to have_selector ".created-questions li", count: 11
    end
  end
  
  scenario "User can view all his answers on the 'answers' tab in profile" do
    answers.each { |a| a.save }
    visit user_path(user.username)

    expect(page).to have_selector ".user-profile-tabs a", text: "answers"
    within(".user-profile-tabs") do
      click_link "answers"
    end

    within(".user-all-answers") do
      expect(page).to have_content "11 Answers"
      expect(page).to have_selector ".created-answers li", count: 11
    end
  end

  scenario "User can view all his comments on the 'comments' tab in profile" do
    comments.each { |c| c.save }
    visit user_path(user.username)

    expect(page).to have_selector ".user-profile-tabs a", text: "comments"
    within(".user-profile-tabs") do
      click_link "comments"
    end

    within(".user-all-comments") do
      expect(page).to have_content "11 Comments"
      expect(page).to have_selector ".created-comments li", count: 11
    end
  end
end

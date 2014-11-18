require_relative "../features_helper"

feature "Search Everywhere" do
  given!(:user) { create(:user)  }

  given!(:questions) { create_list(:question, 2)  }
  given!(:question) { create(:question, title: "This is a question to test searching functionality")  }

  given!(:answer1) { create(:answer, question: questions[0]) }
  given!(:answer2) { create(:answer, question: questions[1]) }
  given!(:answer) { create(:answer, body: "This is an answer to test searching functionality")  }

  given!(:comment1) { create(:answer_comment, commentable: answer1)  }
  given!(:comment2) { create(:answer_comment, commentable: answer2)  }
  given!(:comment3) { create(:question_comment, commentable: questions[0])  }
  given!(:comment4) { create(:question_comment, commentable: questions[1])  }
  given!(:answer_comment) { create(:answer_comment, commentable: answer, body: "This is an answer comment to test searching functionality")  }
  given!(:question_comment) { create(:question_comment, commentable: question, body: "This is a question comment to test searching functionality")  }

  given!(:users) { create_list(:user, 2)  }
  given!(:user_with_name) { create(:user, username: "searching") }
  given!(:user_with_location) { create(:user, location: "searching") }
  given!(:user_with_website) { create(:user, website: "searching") }
  given!(:user_with_full_name) { create(:user, full_name: "searching") }

  background do
    sign_in user
    visit root_path
  end

  scenario "User searches everywhere", js: true do
    expect(page).to have_selector "form#search"
    expect(page).to have_selector "input#search_query"
    expect(page).to have_selector "select#search_target"
    expect(page).to have_selector "input[value='Search']"

    fill_in "search_query", with: "searching"
    select "everywhere", from: "search_target"
    click_button "Search"

    within ".questions" do
      expect(page).to have_content "1 question found"
      expect(page).to have_selector ".question", count: 1
      expect(page).to have_selector ".question-title", text: question.title
    end

    within ".answers" do
      expect(page).to have_content "1 answer found"
      expect(page).to have_selector ".answer", count: 1
      expect(page).to have_selector ".answer-body", text: answer.body
    end

    within ".comments" do
      expect(page).to have_content "2 comments found"
      expect(page).to have_selector ".comment", count: 2
      expect(page).to have_selector ".comment-body", text: answer_comment.body
      expect(page).to have_selector ".comment-body", text: question_comment.body
    end

    within ".users" do
      expect(page).to have_content "4 users found"
      expect(page).to have_selector ".user", count: 4
      expect(page).to have_selector ".username", text: user_with_name.username
      expect(page).to have_selector ".location", text: user_with_name.location
      expect(page).to have_selector ".website", text: user_with_name.website
      expect(page).to have_selector ".full_name", text: user_with_name.full_name
    end
  end

  scenario "User searches everywhere with blank query", js: true do
    fill_in "search_query", with: ""
    select "everywhere", from: "search_target"
    click_button "Search"

    expect(page).to have_content "Nothing was found."
  end
end

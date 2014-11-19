require_relative "../features_helper"

feature "Search Comments" do
  given(:user) { create(:user)  }
  given!(:questions) { create_list(:question, 2)  }
  given!(:answer1) { create(:answer, question: questions[0]) }
  given!(:answer2) { create(:answer, question: questions[1]) }
  given!(:question) { create(:question, title: "This is a question to test searching functionality")  }
  given!(:answer) { create(:answer, body: "This is an answer to test searching functionality")  }
  given!(:comment1) { create(:answer_comment, commentable: answer1)  }
  given!(:comment2) { create(:answer_comment, commentable: answer2)  }
  given!(:comment3) { create(:question_comment, commentable: questions[0])  }
  given!(:comment4) { create(:question_comment, commentable: questions[1])  }
  given!(:answer_comment) { create(:answer_comment, commentable: answer, body: "This is an answer comment to test searching functionality")  }
  given!(:question_comment) { create(:question_comment, commentable: question, body: "This is a question comment to test searching functionality")  }

  given(:pedro) { create(:user, username: "pedro") }
  given(:juan) { create(:user, username: "juan") }
  given(:alejandro) { create(:user, username: "alejandro") }
  given!(:comment_juan) { create(:question_comment, commentable: question, user: juan, body: "This is an comment to test sortings.") }
  given!(:comment_pedro) { create(:question_comment, commentable: question, user: pedro, body: "This is an comment to test sortings.") }
  given!(:comment_alejandro) { create(:question_comment, commentable: question, user: alejandro, body: "This is an comment to test sortings.") }

  background do
    sign_in user
    visit root_path
  end

  scenario "User searches in comments", js: true do
    expect(page).to have_selector "form#search"
    expect(page).to have_selector "input#search_query"
    expect(page).to have_selector "select#search_target"
    expect(page).to have_selector "input[value='Search']"

    fill_in "search_query", with: "searching"
    select "in comments", from: "search_target"
    click_button "Search"

    expect(page).to have_content "2 comments found"
    expect(page).to have_selector ".comment", count: 2
    expect(page).to have_content answer_comment.body
    expect(page).to have_content question_comment.body
  end

  scenario "User searches in comments with blank query", js: true do
    fill_in "search_query", with: ""
    select "in comments", from: "search_target"
    click_button "Search"

    expect(page).to have_content "0 comments found"
    expect(page).not_to have_selector ".comment"
  end

  background do
    comment_pedro.vote_up(user)
    comment_pedro.vote_up(juan)
    comment_juan.vote_up(pedro)
  end

  scenario "Users sorts results of a search", js: true do
    fill_in "search_query", with: "sortings"
    select "in comments", from: "search_target"
    click_button "Search"

    within(".comments-sorting") do
      expect(page).to have_link "relevance"
      expect(page).to have_link "author name"
      expect(page).to have_link "date"
      expect(page).to have_link "popularity"
      
      click_link "author name"
    end
    expect(page).to have_selector "#comment_#{comment_alejandro.id} + #comment_#{comment_juan.id} + #comment_#{comment_pedro.id}"

    within(".comments-sorting") do
      click_link "date"
    end
    expect(page).to have_selector "#comment_#{comment_alejandro.id} + #comment_#{comment_pedro.id} + #comment_#{comment_juan.id}"

    within(".comments-sorting") do
      click_link "popularity"
    end
    expect(page).to have_selector "#comment_#{comment_pedro.id} + #comment_#{comment_juan.id} + #comment_#{comment_alejandro.id}"
  end
end

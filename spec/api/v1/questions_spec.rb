require 'rails_helper'

describe 'Questions API' do
  describe 'GET #index' do
    context "when access token is absent" do
      it "returns 401 status code" do
        get '/api/v1/questions', format: :json
        expect(response.status).to eq 401
      end
    end
    context "when access token is invalid" do
      it "returns 401 status code" do
        get '/api/v1/questions', format: :json, access_token: '12345'
        expect(response.status).to eq 401
      end
    end

    context "when user is authorized" do
      let(:access_token) { create(:access_token) }
      let!(:questions) { create_list(:question, 2) }
      let!(:question) { questions.first }
      let!(:q_comments) { create_list(:question_comment, 2, commentable: question) }
      let!(:q_comment) { q_comments.first }

      before do
        get '/api/v1/questions', format: :json, access_token: access_token.token
      end

      it "returns 200 status code" do
        expect(response).to be_success
      end

      it "returns questions list" do
        expect(response.body).to have_json_size(2)
      end
      
      has = %w(body files has_best_answer id list_of_tags tags_array title votes_sum)
      hasnt = %w(answers)

      it_behaves_like "an API", has, hasnt, "1/", :question

      describe "question comments" do
        it "returns question comments list" do
          expect(response.body).to have_json_size(2).at_path("1/comments")
        end

        has = %w(id body user author commentable_id created edited votes_sum)

        it_behaves_like "an API", has, hasnt, "1/comments/0/", :q_comment

        it "returns question comment commentable" do
          expect(response.body).to have_json_path("1/comments/0/commentable")
        end
      end
    end
  end

  describe 'GET #show' do
    let(:question) { create(:question) }
    let!(:answers) { create_list(:answer, 2, question: question) }
    let!(:answer) { answers.first }
    let!(:q_comments) { create_list(:question_comment, 2, commentable: question) }
    let!(:q_comment) { q_comments.first }
    let!(:a_comments) { create_list(:answer_comment, 2, commentable: answer) }
    let!(:a_comment) { a_comments.first }

    context "when access token is absent" do
      it "returns 401 status code" do
        get "/api/v1/questions/#{question.id}", format: :json
        expect(response.status).to eq 401
      end
    end
    context "when access token is invalid" do
      it "returns 401 status code" do
        get "/api/v1/questions/#{question.id}", format: :json, access_token: '12345'
        expect(response.status).to eq 401
      end
    end

    context "when user is authorized" do
      let(:access_token) { create(:access_token) }

      before do
        get "/api/v1/questions/#{question.id}", format: :json, access_token: access_token.token
      end

      it "returns 200 status code" do
        expect(response).to be_success
      end

      has = %w(body files has_best_answer id list_of_tags tags_array title votes_sum)

      it_behaves_like "an API", has, nil, "", :question

      describe "question comments" do
        it "returns question comments list" do
          expect(response.body).to have_json_size(2).at_path("comments")
        end

        has = %w(id body user author commentable_id created edited votes_sum)

        it_behaves_like "an API", has, nil, "comments/0/", :q_comment

        it "returns question comment commentable" do
          expect(response.body).to have_json_path("comments/0/commentable")
        end
      end

      describe "question answers" do
        it "returns answers list" do
          expect(response.body).to have_json_size(2).at_path("answers")
        end

        has = %w(body created edited files id is_best votes_sum)

        it_behaves_like "an API", has, nil, "answers/1/", :answer

        describe "question answer comments" do
          it "returns answers comments list" do
            expect(response.body).to have_json_size(2).at_path("answers/1/comments")
          end

          has = %w(id body user author commentable_id created edited votes_sum)

          it_behaves_like "an API", has, nil, "answers/1/comments/0/", :a_comment

          it "returns question comment commentable" do
            expect(response.body).to have_json_path("answers/1/comments/0/commentable")
          end
        end

        describe "question answer question" do
          it "returns answer question" do
            expect(response.body).to have_json_path("answers/1/question")
          end

          has = %w(id title body has_best_answer)

          it_behaves_like "an API", has, nil, "answers/1/question/", :question
        end
      end
    end
  end

  describe "POST #create" do
    let(:question) { build(:question) }
    let(:attributes) { attributes_for(:question) }

    context "when user is not authorized" do
      context "when access token is absent" do
        let(:post_create) do
          post '/api/v1/questions', question: attributes, format: :json
        end

        it "returns 401 status code" do
          post_create
          expect(response.status).to eq 401
        end

        it "doesn't create a new question" do
          expect{post_create}.not_to change(Question, :count)
        end
      end
      context "when access token is invalid" do
        let(:post_create) do
          post '/api/v1/questions', question: attributes, format: :json, access_token: '12345'
        end

        it "returns 401 status code" do
          post_create
          expect(response.status).to eq 401
        end

        it "doesn't create a new question" do
          expect{post_create}.not_to change(Question, :count)
        end
      end
    end

    context "when user is authorized" do
      let(:access_token) { create(:access_token) }
      let(:post_create) do
        post '/api/v1/questions', question: attributes, format: :json, access_token: access_token.token
      end

      context "with valid data" do
        it "creates a new question" do
          expect{post_create}.to change(Question, :count).by(1)
        end

        it "returns 201 status code" do
          post_create
          expect(response.status).to eq 201
        end
      end

      context "with invalid data" do
        let(:attributes) { attributes_for(:question, body: "") }

        it "doesn't create a new question" do
          expect{post_create}.not_to change(Question, :count)
        end

        it "returns 422 status code" do
          post_create
          expect(response.status).to eq 422
        end
      end
    end
  end
end

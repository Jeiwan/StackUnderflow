require 'rails_helper'

describe 'Answers API' do
  let(:access_token) { create(:access_token) }
  let(:question) { create(:question) }
  let!(:answers) { create_list(:answer, 2, question: question) }
  let!(:answer) { answers[0] }
  let!(:a_comments) { create_list(:answer_comment, 2, commentable: answer) }
  let!(:a_comment) { a_comments.first }

  describe "GET #index" do
    context "when user is authorized" do
      it_behaves_like "an authenticatable API"

      before do
        get api_v1_question_answers_path(question), format: :json, access_token: access_token.token
      end

      it "returns 200 status code" do
        expect(response).to be_success
      end

      it "returns answers list" do
        expect(response.body).to have_json_size(2)
      end

      has = %w(author body created edited files id is_best votes_sum)

      it_behaves_like "an API", has, nil, "0/", :answer

      describe "answer comments" do
        it "returns answers comments list" do
          expect(response.body).to have_json_size(2).at_path("0/comments")
        end

        has = %w(id body user author commentable_id created edited votes_sum)

        it_behaves_like "an API", has, nil, "0/comments/0/", :a_comment

        it "returns question comment commentable" do
          expect(response.body).to have_json_path("0/comments/0/commentable")
        end
      end

      describe "answer question" do
        it "returns answer question" do
          expect(response.body).to have_json_path("0/question")
        end

        has = %w(id title body has_best_answer)

        it_behaves_like "an API", has, nil, "0/question/", :question
      end
    end

    def request_json(options = {})
      get "/api/v1/questions/#{question.id}", {format: :json}.merge(options)
    end
  end

  describe "GET #show" do
    let(:question) { create(:question) }
    let!(:answer) { create(:answer, question: question) }

    it_behaves_like "an authenticatable API"

    context "when user is authorized" do
      let(:access_token) { create(:access_token) }

      before do
        get api_v1_answer_path(answer), format: :json, access_token: access_token.token
      end

      it "returns 200 status code" do
        expect(response).to be_success
      end

      has = %w(body created edited files id is_best votes_sum author)

      it_behaves_like "an API", has, nil, "", :answer

      describe "answer comments" do
        it "returns answers comments list" do
          expect(response.body).to have_json_size(2).at_path("comments")
        end

        has = %w(id body user author commentable_id created edited votes_sum)

        it_behaves_like "an API", has, nil, "comments/0/", :a_comment

        it "returns question comment commentable" do
          expect(response.body).to have_json_path("comments/0/commentable")
        end
      end

      describe "answer question" do
        it "returns answer question" do
          expect(response.body).to have_json_path("question")
        end

        has = %w(id title body has_best_answer)

        it_behaves_like "an API", has, nil, "question/", :question
      end
    end

    def request_json(options = {})
      get "/api/v1/answers/#{answer.id}", {format: :json}.merge(options)
    end
  end

  describe "POST #create" do
    let!(:question) { create(:question) }
    let(:answer) { build(:answer) }
    let(:attributes) { attributes_for(:answer) }

    context "when user is not authorized" do
      context "when access token is absent" do
        let(:post_create) do
          post "/api/v1/questions/#{question.id}/answers", answer: attributes, format: :json
        end

        it "returns 401 status code" do
          post_create
          expect(response.status).to eq 401
        end

        it "doesn't create a new answer" do
          expect{post_create}.not_to change(Answer, :count)
        end
      end
      context "when access token is invalid" do
        let(:post_create) do
          post "/api/v1/questions/#{question.id}/answers", answer: attributes, format: :json, access_token: '12345'
        end

        it "returns 401 status code" do
          post_create
          expect(response.status).to eq 401
        end

        it "doesn't create a new answer" do
          expect{post_create}.not_to change(Answer, :count)
        end
      end
    end

    context "when user is authorized" do
      let(:access_token) { create(:access_token) }
      let(:post_create) do
        post "/api/v1/questions/#{question.id}/answers", answer: attributes, format: :json, access_token: access_token.token
      end

      context "with valid data" do
        it "creates a new answer" do
          expect{post_create}.to change(Answer, :count).by(1)
        end

        it "returns 201 status code" do
          post_create
          expect(response.status).to eq 201
        end
      end

      context "with invalid data" do
        let(:attributes) { attributes_for(:answer, body: "") }

        it "doesn't create a new answer" do
          expect{post_create}.not_to change(Answer, :count)
        end

        it "returns 422 status code" do
          post_create
          expect(response.status).to eq 422
        end
      end
    end
  end
end


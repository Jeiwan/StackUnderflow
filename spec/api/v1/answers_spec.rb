require 'rails_helper'

describe 'Answers API' do
  let(:question) { create(:question) }
  let!(:answers) { create_list(:answer, 2, question: question) }
  let!(:answer) { answers[0] }
  let!(:a_comments) { create_list(:answer_comment, 2, commentable: answer) }
  let!(:a_comment) { a_comments.first }

  describe "GET #index" do
    context "when access token is absent" do
      it "returns 401 status code" do
        get api_v1_question_answers_path(question), format: :json
        expect(response.status).to eq 401
      end
    end

    context "when access token is invalid" do
      it "returns 401 status code" do
        get api_v1_question_answers_path(question), format: :json, access_token: '12345'
        expect(response.status).to eq 401
      end
    end

    context "when user is authorized" do
      let(:access_token) { create(:access_token) }

      before do
        get api_v1_question_answers_path(question), format: :json, access_token: access_token.token
      end

      it "returns 200 status code" do
        expect(response).to be_success
      end

      it "returns answers list" do
        expect(response.body).to have_json_size(2)
      end

      %w(body created edited files id is_best votes_sum author).each do |attr|
        it "returns answer #{attr}" do
          if answer.respond_to?(attr.to_sym)
            expect(response.body).to be_json_eql(answer.send(attr.to_sym).to_json).at_path("1/#{attr}")
          else
            expect(response.body).to have_json_path("1/#{attr}")
          end
        end
      end
    end
  end

  describe "GET #show" do
    let(:question) { create(:question) }
    let!(:answer) { create(:answer, question: question) }

    context "when access token is absent" do
      it "returns 401 status code" do
        get api_v1_answer_path(answer), format: :json
        expect(response.status).to eq 401
      end
    end

    context "when access token is invalid" do
      it "returns 401 status code" do
        get api_v1_answer_path(answer), format: :json, access_token: '12345'
        expect(response.status).to eq 401
      end
    end

    context "when user is authorized" do
      let(:access_token) { create(:access_token) }

      before do
        get api_v1_answer_path(answer), format: :json, access_token: access_token.token
      end

      it "returns 200 status code" do
        expect(response).to be_success
      end

      %w(body created edited files id is_best votes_sum).each do |attr|
        it "returns answer #{attr}" do
          if answer.respond_to?(attr.to_sym)
            expect(response.body).to be_json_eql(answer.send(attr.to_sym).to_json).at_path(attr)
          else
            expect(response.body).to have_json_path(attr)
          end
        end
      end

      describe "question answer comments" do
        it "returns answers comments list" do
          expect(response.body).to have_json_size(2).at_path("comments")
        end

        %w(id body user author commentable_id created edited votes_sum).each do |attr|
          it "returns question comment #{attr}" do
            if a_comment.respond_to?(attr.to_sym)
              expect(response.body).to be_json_eql(a_comment.send(attr.to_sym).to_json).at_path("comments/0/#{attr}")
            else
              expect(response.body).to have_json_path("comments/0/#{attr}")
            end
          end
        end

        it "returns question comment commentable" do
          expect(response.body).to have_json_path("comments/0/commentable")
        end
      end

      describe "question answer question" do
        it "returns answer question" do
          expect(response.body).to have_json_path("question")
        end

        %w(id title body has_best_answer).each do |attr|
          it "returns answer question #{attr}" do
            if answer.question.respond_to?(attr.to_sym)
              expect(response.body).to be_json_eql(answer.question.send(attr.to_sym).to_json).at_path("question/#{attr}")
            else
              expect(response.body).to have_json_path("question/#{attr}")
            end
          end
        end
      end
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

      it "creates a new answer" do
        expect{post_create}.to change(Answer, :count).by(1)
      end

      it "returns 201 status code" do
        post_create
        expect(response.status).to eq 201
      end
    end
  end
end

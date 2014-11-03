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
      let!(:answers) { create_list(:answer, 2, question: question) }
      let!(:answer) { answers.first }
      let!(:q_comments) { create_list(:question_comment, 2, commentable: question) }
      let!(:q_comment) { q_comments.first }
      let!(:a_comments) { create_list(:answer_comment, 2, commentable: answer) }
      let!(:a_comment) { a_comments.first }

      before do
        get '/api/v1/questions', format: :json, access_token: access_token.token
      end

      it "returns 200 status code" do
        expect(response).to be_success
      end

      it "returns questions list" do
        expect(response.body).to have_json_size(2)
      end
      
      %w(body files has_best_answer id list_of_tags tags_array title votes_sum).each do |attr|
        it "returns question #{attr}" do
          if question.respond_to?(attr.to_sym)
            expect(response.body).to be_json_eql(question.send(attr.to_sym).to_json).at_path("1/#{attr}")
          else
            expect(response.body).to have_json_path("1/#{attr}")
          end
        end
      end

      describe "question comments" do
        it "returns question comments list" do
          expect(response.body).to have_json_size(2).at_path("1/comments")
        end

        %w(id body user author commentable_id created edited votes_sum).each do |attr|
          it "returns question comment #{attr}" do
            if q_comment.respond_to?(attr.to_sym)
              expect(response.body).to be_json_eql(q_comment.send(attr.to_sym).to_json).at_path("1/comments/0/#{attr}")
            else
              expect(response.body).to have_json_path("1/comments/0/#{attr}")
            end
          end
        end

        it "returns question comment commentable" do
          expect(response.body).to have_json_path("1/comments/0/commentable")
        end
      end

      describe "question answers" do
        it "returns answers list" do
          expect(response.body).to have_json_size(2).at_path("1/answers")
        end

        %w(body created edited files id is_best votes_sum).each do |attr|
          it "returns answer #{attr}" do
            if answer.respond_to?(attr.to_sym)
              expect(response.body).to be_json_eql(answer.send(attr.to_sym).to_json).at_path("1/answers/1/#{attr}")
            else
              expect(response.body).to have_json_path("1/answers/1/#{attr}")
            end
          end
        end

        describe "question answer comments" do
          it "returns answers comments list" do
            expect(response.body).to have_json_size(2).at_path("1/answers/1/comments")
          end

          %w(id body user author commentable_id created edited votes_sum).each do |attr|
            it "returns question comment #{attr}" do
              if a_comment.respond_to?(attr.to_sym)
                expect(response.body).to be_json_eql(a_comment.send(attr.to_sym).to_json).at_path("1/answers/1/comments/0/#{attr}")
              else
                expect(response.body).to have_json_path("1/answers/1/comments/0/#{attr}")
              end
            end
          end

          it "returns question comment commentable" do
            expect(response.body).to have_json_path("1/answers/1/comments/0/commentable")
          end
        end

        describe "question answer question" do
          it "returns answer question" do
            expect(response.body).to have_json_path("1/answers/1/question")
          end

          %w(id title body has_best_answer).each do |attr|
            it "returns answer question #{attr}" do
              if answer.question.respond_to?(attr.to_sym)
                expect(response.body).to be_json_eql(answer.question.send(attr.to_sym).to_json).at_path("1/answers/1/question/#{attr}")
              else
                expect(response.body).to have_json_path("1/answers/1/question/#{attr}")
              end
            end
          end
        end
      end
    end
  end
end

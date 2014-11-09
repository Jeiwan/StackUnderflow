require 'rails_helper'

RSpec.describe AnswersController, :type => :controller do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:question) { create(:question, user: user2) }
  let(:answer) { create(:answer, question: question, user: user) }

  user_sign_in

  describe "POST #create" do
    let(:attributes) { attributes_for :answer } 
    let(:post_create) do
      post :create, question_id: question.id, answer: attributes, format: :json
    end

    context "when signed in", sign_in: true do
      context "with valid data" do
        it "increases a total number of answers" do
          expect{post_create}.to change(question.answers, :count).by(1)
        end

        it "increases a total number of user's answers" do
          expect{post_create}.to change(user.answers, :count).by(1)
        end

        it "updates question's recent_activity field" do
          expect{post_create}.to change{question.reload.recent_activity}
        end

        it "publishes a message to PrivatePub" do
          expect(PrivatePub).to receive(:publish_to)
          post_create
        end

        it "returns 201 status code" do
          post_create
          expect(response.status).to eq 201
        end
      end

      context "with invalid data" do
        let(:attributes) { attributes_for :answer, body: nil }

        it "doesn't increase a total number of answers" do
          expect{post_create}.not_to change(question.answers, :count)
        end

        it "doesn't increase a total number of user's answers" do
          expect{post_create}.not_to change(user.answers, :count)
        end

        it "doesn't update question's recent_activity field" do
          expect{post_create}.not_to change{question.reload.recent_activity}
        end

        it "returns 422 status code" do
          post_create
          expect(response.status).to eq 422
        end
      end
    end

    context "when not signed in" do
      before { post_create }

      it "doesn't create a new answer" do
        expect{post_create}.not_to change(question.answers, :count)
      end

      it "return 401 error" do
        expect(response.status).to eq 401
      end
    end
  end

  describe "PUT #update" do
    let(:edited_answer) do
      edited_answer = answer.dup
      edited_answer.body = answer.body.reverse
      edited_answer
    end
    let(:put_update) do
      put :update, question_id: question.id, id: answer.id, answer: {body: edited_answer.body}, format: :json
    end

    context "when signed in", sign_in: true do
      context "when answer belong to current user" do
        context "with valid information" do
          it "changes answer's field" do
            put_update
            expect(Answer.find(answer.id).body).to eq edited_answer.body
          end

          it "updates question's recent_activity field" do
            expect{put_update}.to change(question.reload, :recent_activity)
          end

          it "returns 200 status" do
            put_update
            expect(response.status).to eq 200
          end
        end

        context "with invalid information" do
          before do
            edited_answer.body = nil
            put_update
          end

          it "doesn't change answer's field" do
            expect(answer.body).not_to eq edited_answer.body
          end

          it "doesn't update question's recent_activity field" do
            expect{put_update}.not_to change{question.reload.recent_activity}
          end

          it "returns 422 status" do
            expect(response.status).to eq 422
          end
        end
      end

      context "when answer doesn't belong to current user" do
        let(:answer) { create(:answer, question: question, user: user2) }
        before { put_update }

        it "doesn't change answer's field" do
          expect(answer.body).not_to eq edited_answer.body
        end

        it "returns 401 status code" do
          expect(response.status).to eq 401
        end
      end
    end

    context "when not signed in" do
      before { put_update }

      it "doesn't change answer's attribute" do
        expect(answer.body).not_to eq edited_answer.body
      end
      
      it "returns 401 error" do
        expect(response.status).to eq 401
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:comment) { create(:answer_comment, commentable: answer) }
    let!(:vote) { create(:vote, votable: answer, user: user2) }
    let(:delete_destroy) do
      delete :destroy, question_id: question, id: answer, format: :json
    end
    before { answer }

    context "when signed in", sign_in: true do
      context "when asnwer belongs to current user" do
        it "deletes the answer" do
          expect{delete_destroy}.to change(Answer, :count).by(-1)
        end

        it "deletes comments to the answer" do
          expect{delete_destroy}.to change(Comment, :count).by(-1)
        end

        it "removes relating votes" do
          expect{delete_destroy}.to change(Vote, :count).by(-1)
        end

        it "publishes a message to PrivatePub" do
          expect(PrivatePub).to receive(:publish_to)
          delete_destroy
        end

        it "returns 204 code" do
          delete_destroy
          expect(response.status).to eq 204
        end
      end

      context "when answer doesn't belong to current user" do
        let(:answer) { create(:answer, question: question, user: user2) }

        it "doesn't delete the answer" do
          expect{delete_destroy}.not_to change(Answer, :count)
        end
        
        it "returns 401 status code" do
          delete_destroy
          expect(response.status).to eq 401
        end
      end
    end

    context "when not signed in" do
      it "doesn't delete the answer" do
        expect{delete_destroy}.not_to change(Answer, :count)
      end

      it "returns 401 error" do
        delete_destroy
        expect(response.status).to eq 401
      end
    end
  end

  describe "POST #mark_best" do
    let(:mark_best) do
      post :mark_best, question_id: question, id: answer
    end

    context "when signed in", sign_in: true do
      context "when question belongs to current user" do
        let(:question) { create(:question, user: user) }
        let(:answer) { create(:answer, question: question, user: user2) }

        context "when question has no best answers" do
          before { mark_best }

          it "marks the answer as best" do
            expect(answer.reload).to be_best
          end

          it "redirects to question page" do
            expect(response).to redirect_to question
          end
        end

        context "when question already has a best answer" do
          let!(:best_answer) { create(:answer, question: question, user: user2, best: true) }
          before { mark_best }

          it "doesn't mark the answer as best" do
            expect(answer.reload).not_to be_best
          end

          it "redirects to root path" do
            expect(response).to redirect_to root_path
          end
        end
      end

      context "when question doesn't belong to current user" do
        before { mark_best }
        it "redirects to root path" do
          expect(response).to redirect_to root_path
        end
      end
    end

    context "when not signed in" do
      before { mark_best }
      it "doesn't mark the answer as best" do
        expect(answer.reload).not_to be_best
      end

      it "redirects to sign in page" do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end

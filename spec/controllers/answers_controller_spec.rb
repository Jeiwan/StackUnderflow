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
      post :create, question_id: question.id, answer: attributes, format: :js
    end

    context "when signed in", sign_in: true do
      context "with valid data" do
        it "increases a total number of answers" do
          expect{post_create}.to change(question.answers, :count).by(1)
        end

        it "increases a total number of user's answers" do
          expect{post_create}.to change(user.answers, :count).by(1)
        end

        it "redirects to the question's show page" do
          post_create
          expect(response).to render_template :create
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

        it "redirects to the question's show page" do
          post_create
          expect(response).to render_template :create
        end
      end
    end

    context "when not signed in" do
      before { post_create }
      it "redirects to sign in page" do
        #expect(response).to redirect_to new_user_session_path
        expect(response.status).to eq 401
      end
    end
  end

  describe "GET #edit" do
    let(:get_edit) do
      get :edit, question_id: question.id, id: answer.id
    end

    context "when signed in", sign_in: true do
      context "when answer belongs to current user" do
        before { get_edit }

        it "returns an answer" do
          expect(assigns[:answer]).to eq answer
        end
        it "renders edit view" do
          expect(response).to render_template :edit
        end
      end

      context "when answer doesn't belong to current user" do
        let(:answer) { create(:answer, question: question, user: user2) }
        before do
          get_edit
        end

        it "redirects to root path" do
          expect(response).to redirect_to root_path
        end
      end
    end

    context "when not signed in" do
      before { get_edit }
      it "redirects to sign in page" do
        expect(response).to redirect_to new_user_session_path
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
      put :update, question_id: question.id, id: answer.id, answer: {body: edited_answer.body}
    end

    context "when signed in", sign_in: true do
      context "when answer belong to current user" do
        context "with valid information" do
          before { put_update }

          it "changes answer's field" do
            expect(Answer.find(answer.id).body).to eq edited_answer.body
          end

          it "redirects to the answer's question page" do
            expect(response).to redirect_to question_path(question.id)
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

          it "renders edit view" do
            expect(response).to render_template "edit"
          end
        end
      end

      context "when answer doesn't belong to current user" do
        let(:answer) { create(:answer, question: question, user: user2) }
        before { put_update }

        it "doesn't change answer's field" do
          expect(answer.body).not_to eq edited_answer.body
        end

        it "redirects to root path" do
          expect(response).to redirect_to root_path
        end
      end
    end

    context "when not signed in" do
      before { put_update }

      it "doesn't change answer's attribute" do
        expect(answer.body).not_to eq edited_answer.body
      end
      
      it "redirects to sign in page" do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "DELETE #destroy" do
    let(:delete_destroy) do
      delete :destroy, question_id: question, id: answer, format: :js
    end
    before { answer }

    context "when signed in", sign_in: true do
      context "when asnwer belongs to current user" do
        it "deletes the answer" do
          expect{delete_destroy}.to change(Answer, :count).by(-1)
        end

        it "redirects to root path" do
          delete_destroy
          expect(response).to render_template :destroy
        end
      end

      context "when answer doesn't belong to current user" do
        let(:answer) { create(:answer, question: question, user: user2) }

        it "doesn't delete the answer" do
          expect{delete_destroy}.not_to change(Answer, :count)
        end
        
        it" redirects to root path" do
          delete_destroy
          expect(response).to redirect_to root_path
        end
      end
    end

    context "when not signed in" do
      it "doesn't delete the answer" do
        expect{delete_destroy}.not_to change(Answer, :count)
      end

      it "redirects to sign in path" do
        delete_destroy
        #expect(response).to redirect_to new_user_session_path
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

          it "redirects to question page" do
            expect(response).to redirect_to question
          end
        end
      end

      context "when question doesn't belong to current user" do
        before { mark_best }
        it "redirects to question page" do
          expect(response).to redirect_to question
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

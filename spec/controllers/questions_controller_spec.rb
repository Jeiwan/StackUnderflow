require 'rails_helper'

RSpec.describe QuestionsController, :type => :controller do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:question2) { create(:question, user: user2) }

  user_sign_in

  describe "GET #index" do
    let(:questions) { create_list(:question, 2) }
    before { get :index }

    it "returns a list of questions" do
      expect(assigns(:questions)).to match_array(questions)
    end

    it "renders index view" do
      expect(response).to render_template :index
    end
  end

  describe "GET #new" do
    before { get :new }

    context "when not signed in" do
      it "redirects to sign in page" do
        expect(response).to redirect_to new_user_session_path
      end
    end

    context "when signed in", sign_in: true do
      it "returns a new empty question" do
        expect(assigns(:question)).to be_a_new(Question)
      end

      it "returns a new empty attachment for the question" do
        expect(assigns(:question).attachments.first).to be_a_new(Attachment)
      end

      it "renders new view" do
        expect(response).to render_template :new
      end
    end
  end

  describe "GET #show" do
    before { get :show, id: question.id }

    it "returns a question" do
      expect(assigns(:question)).to eq question
    end

    it "returns a new empty attachment for the answer" do
      expect(assigns(:answer).attachments.first).to be_a_new(Attachment)
    end

    it "renders show view" do
      expect(response).to render_template :show
    end
  end

  describe "POST #create" do
    let(:attributes) { attributes_for(:question) }
    let(:post_create) do
      post :create, question: attributes
    end

    context "when signed in", sign_in: true do
      context "with valid data" do
        context "with a new tag" do
          it "increases number of tags" do
            expect{post_create}.to change(Tag, :count).by(5)
          end

          it "increases total number of questions" do
            expect{post_create}.to change(Question, :count).by(1)
          end

          it "increases current user's number of questions" do
            expect{post_create}.to change(Question, :count).by(1)
          end

          it "redirects to the new question page" do
            post_create
            expect(response).to redirect_to(assigns(:question))
          end
        end

        context "with existing tags" do
          let!(:tag) { create(:tag) }
          let(:attributes) { attributes_for(:question, tag_list: "#{tag.name},windows,c++,macosx") }

          it "increases number of tags" do
            expect{post_create}.to change(Tag, :count).by(3)
          end

          it "increases total number of questions" do
            expect{post_create}.to change(Question, :count).by(1)
          end

          it "increases current user's number of questions" do
            expect{post_create}.to change(Question, :count).by(1)
          end

          it "redirects to the new question page" do
            post_create
            expect(response).to redirect_to(assigns(:question))
          end
        end

      end

      context "with invalid data" do
        let(:attributes) { attributes_for(:question, title: nil, body: nil) }

        it "doesn't increase total questions count" do
          expect{post_create}.not_to change(Question, :count)
        end

        it "doesn't increase current user's questions count" do
          expect{post_create}.not_to change(Question, :count)
        end

        it "renders new view" do
          post_create
          expect(response).to render_template :new
        end
      end
    end

    context "when not signed in" do
      before { post_create }
      it "redirects to the sign in page" do
        expect(response).to redirect_to new_user_session_path
      end
    end

  end

  describe "PUT #update" do
    let(:edited_question) do
      edited = question.dup
      edited.title = question.title.reverse
      edited
    end
    let(:put_update) do
      put :update, id: question.id, question: { title: edited_question.title, body: question.body, tag_list: question.tag_list }, format: :js
    end

    context "when signed in", sign_in: true do
      context "when question belongs to current user" do
        context "with valid data" do
          before { put_update }

          it "changes question's attribute" do
            expect(question.reload.title).to eq edited_question.title
          end

          it "return 200 status" do
            expect(response.status).to eq 200
          end
        end

        context "with invalid data" do
          before do 
            edited_question.title = nil
            put_update
          end

          it "doesn't change question's attribute" do
            expect(question.reload.title).not_to eq edited_question.title
          end

          it "returns 422 status" do
            expect(response.status).to eq 422
          end
        end
      end

      context "when question doesn't belong to current user" do
        let(:question) { question2 }
        before { put_update }

        it "renders root page" do
          expect(response).to redirect_to root_path
        end
      end
    end

    context "when not signed in" do
      before { put_update }

      it "doesn't change question's attribute" do
        expect(question.reload.title).not_to eq edited_question.title
      end

      it "returns 401 error" do
        expect(response.status).to eq 401
      end
    end

  end

  describe "DELETE #destroy" do
    let!(:answer) { create(:answer, question: question) }
    let!(:comment) { create(:question_comment, commentable: question) }
    let(:delete_destroy) do
      delete :destroy, id: question
    end

    before { question }

    context "when signed in", sign_in: true do
      context "when question belongs to current user" do
        it "removes a question" do
          expect{delete_destroy}.to change(Question, :count).by(-1)
        end

        it "removes answers for the question" do
          expect{delete_destroy}.to change(Answer, :count).by(-1)
        end

        it "removes comments to the question" do
          expect{delete_destroy}.to change(Comment, :count).by(-1)
        end

        it "redirects to root path" do
          delete_destroy
          expect(response).to redirect_to root_path
        end
      end
      
      context "when question doesn't belong to current user" do
        let(:question) { question2 }
        before { delete_destroy }

        it "redirects to root path" do
          expect(response).to redirect_to root_path
        end
      end
    end

    context "when not signed in" do
      it "doesn't delete a question" do
        expect{delete_destroy}.not_to change(Question, :count)
      end

      it "redirects to root path" do
        delete_destroy
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "PATCH #vote" do
    let(:patch_vote_up) do
      patch :vote, id: question2, vote: :up, format: :json
      question2.reload
    end
    let(:patch_vote_down) do
      patch :vote, id: question2, vote: :down, format: :json
      question2.reload
    end

    context "when signed in", sign_in: true do
      context "when question doesn't belong to current user" do
        context "when voting up" do
          it "increases question's votes" do
            expect{patch_vote_up}.to change(question2, :votes).by(1)
          end

          it "sets question's votes" do
            patch_vote_up
            expect(question2.votes).to eq 1
          end

          it "assigns @question" do
            patch_vote_up
            expect(assigns(:question)).to eq question2
          end

          it "returns status 200" do
            patch_vote_up
            expect(response.status).to eq 200
          end

          it "returns votes" do
            patch_vote_up
            expect(response.body).to include "votes"
          end
        end

        context "when voting down" do
          it "decreases question's votes" do
            expect{patch_vote_down}.to change(question2, :votes).by(-1)
          end

          it "sets question's votes" do
            patch_vote_down
            expect(question2.reload.votes).to eq -1
          end

          it "assigns @question" do
            patch_vote_down
            expect(assigns(:question)).to eq question2
          end

          it "returns status 200" do
            patch_vote_down
            expect(response.status).to eq 200
          end

          it "returns votes" do
            patch_vote_down
            expect(response.body).to include "votes"
          end
        end
      end

      context "when question belongs to current user" do
        context "when voting up" do
          let(:patch_vote_up) do
            post :vote, id: question, vote: :down, format: :json
          end

          it "doesn't increase question's votes" do
            expect{patch_vote_up}.not_to change(question, :votes)
          end

          it "assigns @question" do
            patch_vote_up
            expect(assigns(:question)).to eq question
          end

          it "returns status 501" do
            patch_vote_up
            expect(response.status).to eq 501
          end
        end

        context "when voting down" do
          let(:patch_vote_down) do
            post :vote, id: question, vote: :down, format: :json
          end

          it "doesn't increase question's votes" do
            expect{patch_vote_down}.not_to change(question, :votes)
          end

          it "assigns @question" do
            patch_vote_down
            expect(assigns(:question)).to eq question
          end

          it "returns status 501" do
            patch_vote_down
            expect(response.status).to eq 501
          end
        end
      end
    end

    context "when not signed in" do
      it "doesn't increase question's votes" do
        expect{patch_vote_up}.not_to change(question2, :votes)
      end

      it "returns 401 status code" do
        patch_vote_up
        expect(response.status).to eq 401
      end
    end
  end
end

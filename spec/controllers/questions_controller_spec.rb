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

  describe "GET #edit" do
    let(:get_edit) do
      xhr :get, :edit, id: question.id, format: :js
    end

    context "when signed in", sign_in: true do
      context "when question belongs to current user" do
        before { get_edit }

        it "returns a question" do
          expect(assigns(:question)).to eq question
        end

        it "renders edit view" do
          expect(response).to render_template "edit"
        end
      end

      context "when question doesn't belong to current user" do
        let(:question) { question2 }
        before { get_edit }

        it "redirects to root page" do
          expect(response).to redirect_to root_path
        end
      end
    end

    context "when not signed in" do
      before { get_edit } 

      it "redirects to the sign in page" do
        expect(response.status).to eq 401
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
      put :update, id: question.id, question: { title: edited_question.title, body: question.body }, format: :js
    end

    context "when signed in", sign_in: true do
      context "when question belongs to current user" do
        context "with valid data" do
          before { put_update }

          it "changes question's attribute" do
            expect(question.reload.title).to eq edited_question.title
          end

          it "render update view" do
            expect(response).to render_template :update
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

          it "renders update view" do
            expect(response).to render_template :update
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

      it "redirects to the sign in page" do
        expect(response.status).to eq 401
      end
    end

  end

  describe "DELETE #destroy" do
    let(:delete_destroy) do
      delete :destroy, id: question
    end

    before { question }

    context "when signed in", sign_in: true do
      context "when question belongs to current user" do
        it "removes a question" do
          expect{delete_destroy}.to change(Question, :count).by(-1)
        end

        it "redirects to root path" do
          delete_destroy
          expect(response).to redirect_to root_path
        end
      end
      
      context "when question doesn't belong to current user" do
        let(:question) { question2 }
        before { delete_destroy }

        it "renders root page" do
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
end

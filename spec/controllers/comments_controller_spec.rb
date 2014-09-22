require 'rails_helper'

RSpec.describe CommentsController, :type => :controller do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:comment) { create(:question_comment, user: user, commentable: question) }

  user_sign_in

  describe "POST #create" do
    let(:attributes) { attributes_for(:question_comment) }
    let(:post_create) do
      post :create, question_id: question.id, comment: attributes
    end

    context "when signed in", sign_in: true do
      context "with valid data" do
        it "adds a new comment to database" do
          expect{post_create}.to change(Comment, :count).by(1)
        end
        it "redirects to the question page" do
          post_create
          expect(response).to redirect_to question_path(question)
        end
      end

      context "with invalid data" do
        let(:attributes) { attributes_for(:question_comment, body: nil) }
        it "doesn't add a new comment to database" do
          expect{post_create}.not_to change(Comment, :count)
        end
        it "redirects to the question page" do
          post_create
          expect(response).to redirect_to question_path(question)
        end
      end
    end

    context "when not signed in" do
      it "redirects to the sign in page" do
        post_create
        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe "GET #edit" do
    let(:get_edit) do
      get :edit, question_id: question.id, id: comment.id
    end

    context "when signed in", sign_in: true do
      context "when comment belongs to current user" do
        before { get_edit }

        it "returns a comment" do
          expect(assigns(:comment)).to eq comment
        end

        it "renders edit view" do
          expect(response).to render_template :edit
        end
      end

      context "when comment doesn't belong to current user" do
        let(:comment) { create(:question_comment, user: user2, commentable: question) }
        before { get_edit }

        it "redirects to question page" do
          expect(response).to redirect_to question_path(question)
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
    let(:attributes) { attributes_for(:question_comment, body: comment.body.reverse) }
    let(:put_update) do
      put :update, question_id: question.id, id: comment.id, comment: attributes
    end

    context "when signed in", sign_in: true do
      context "comment belongs to current user" do
        context "with valid data" do
          before { put_update }

          it "changes comment's attribute" do
            #expect(comment.body.reverse).to eq comment.reload.body
            expect(comment.reload.body).to eq attributes[:body]
          end

          it "redirects to question page" do
            expect(response).to redirect_to question_path(question)
          end
        end

        context "with invalid data" do
          let(:attributes) { attributes_for(:question_comment, body: "") }
          before { put_update }

          it "doesn't change comment's attribute" do
            expect(comment.reload.body).not_to eq attributes[:body]
          end

          it "renders edit view" do
            expect(response).to render_template :edit
          end
        end
      end

      context "comment doesn't belong to current user" do
        let(:user) { user2 }
        before { put_update }

        it "redirects to question page" do
          expect(response).to redirect_to question_path(question)
        end
      end
    end

    context "when not signed in" do
      before { put_update }

      it "redirects to sign in page" do
        expect(response).to redirect_to new_user_session_path
      end
    end
  end
end

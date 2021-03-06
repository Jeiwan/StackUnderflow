require 'rails_helper'

RSpec.describe CommentsController, :type => :controller do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:question) { create(:question, user: user) }
  let!(:comment) { create(:question_comment, user: user, commentable: question) }
  let!(:comment2) { create(:question_comment, user: user2, commentable: question) }

  user_sign_in

  describe "POST #create" do
    let(:attributes) { attributes_for(:question_comment) }
    let(:post_create) do
      post :create, question_id: question.id, comment: attributes, format: :json
    end

    context "when signed in", sign_in: true do
      context "with valid data" do
        it "adds a new comment to database" do
          expect{post_create}.to change(Comment, :count).by(1)
        end
        it "updates question's activity" do
          expect{post_create}.to change{question.reload.recent_activity}
        end
        it "publishes a message to PrivatePub" do
          expect(PrivatePub).to receive(:publish_to)
          post_create
        end
        it "returns 201 status" do
          post_create
          expect(response.status).to eq 201
        end
      end

      context "with invalid data" do
        let(:attributes) { attributes_for(:question_comment, body: nil) }
        it "doesn't add a new comment to database" do
          expect{post_create}.not_to change(Comment, :count)
        end
        it "returns 422 status" do
          post_create
          expect(response.status).to eq 422
        end
      end
    end

    context "returns 401 error" do
      it "redirects to the sign in page" do
        post_create
        expect(response.status).to eq 401
      end
    end
  end

  describe "PUT #update" do
    let(:attributes) { attributes_for(:question_comment, body: comment.body.reverse) }
    let(:put_update) do
      put :update, question_id: question.id, id: comment.id, comment: attributes, format: :json
    end

    context "when signed in", sign_in: true do
      context "comment belongs to current user" do
        context "with valid data" do
          before { put_update }

          it "changes comment's attribute" do
            expect(comment.reload.body).to eq attributes[:body]
          end

          it "returns 200 status" do
            expect(response.status).to eq 200
          end
        end

        context "with invalid data" do
          let(:attributes) { attributes_for(:question_comment, body: "") }
          before { put_update }

          it "doesn't change comment's attribute" do
            expect(comment.reload.body).not_to eq attributes[:body]
          end

          it "returns 422 status" do
            expect(response.status).to eq 422
          end
        end
      end

      context "when comment doesn't belong to current user" do
        let(:comment) { comment2 }
        before { put_update }

        it "returns 401 error" do
          expect(response.status).to eq 401
        end
      end
    end

    context "when not signed in" do
      before { put_update }

      it "returns 401 error" do
        expect(response.status).to eq 401
      end
    end
  end

  describe "DELETE #destroy" do
    let(:delete_destroy) do
      delete :destroy, question_id: question.id, id: comment.id, format: :json
    end

    context "when signed in", sign_in: true do
      context "when comment belongs to current user" do
        it "removes the comment" do
          expect{delete_destroy}.to change(Comment, :count).by(-1)
        end

        it "publishes a message to PrivatePub" do
          expect(PrivatePub).to receive(:publish_to)
          delete_destroy
        end

        it "returns 204 status" do
          delete_destroy
          expect(response.status).to eq 204
        end
      end

      context "when comment doesn't belong to current user" do
        let(:comment) { comment2 }
        it "doesn't remove the comment" do
          expect{delete_destroy}.not_to change(Comment, :count)
        end

        it "returns 401 error" do
          delete_destroy
          expect(response.status).to eq 401
        end
      end
    end

    context "when not signed in" do
      it "returns 401 error" do
        delete_destroy
        expect(response.status).to eq 401
      end
    end
  end
end

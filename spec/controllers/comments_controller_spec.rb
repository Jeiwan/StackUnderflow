require 'rails_helper'

RSpec.describe CommentsController, :type => :controller do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:comment) { build(:comment, user: user) }

  user_sign_in

  describe "POST #create" do
    let(:attributes) { attributes_for(:comment) }
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
        let(:attributes) { attributes_for(:comment, body: nil) }
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

end

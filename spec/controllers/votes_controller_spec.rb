require 'rails_helper'

RSpec.describe VotesController, :type => :controller do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:answer) { create(:answer, question: question, user: user) }
  let(:comment) { create(:answer_comment, commentable: answer, user: user) }
  let(:comment2) { create(:answer_comment, commentable: answer, user: user2) }

  user_sign_in

  describe "PATCH #vote_up" do
    let(:patch_vote_up) do
      patch :vote_up, id: comment2, format: :json
      comment2.reload
    end

    context "when signed in", sign_in: true do
      context "when comment doesn't belong to current user" do
        it "increases comment's votes" do
          expect{patch_vote_up}.to change(comment2, :votes_sum).by(1)
        end

        it "sets comment's votes" do
          patch_vote_up
          expect(comment2.votes_sum).to eq 1
        end

        it "assigns @comment" do
          patch_vote_up
          expect(assigns(:parent)).to eq comment2
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

      context "when comment belongs to current user" do
        let(:patch_vote_up) do
          post :vote_up, id: comment, format: :json
        end

        it "doesn't increase comment's votes" do
          expect{patch_vote_up}.not_to change(comment, :votes_sum)
        end

        it "assigns @comment" do
          patch_vote_up
          expect(assigns(:parent)).to eq comment
        end

        it "returns status 403" do
          patch_vote_up
          expect(response.status).to eq 403
        end
      end
    end

    context "when not signed in" do
      it "doesn't increase comment's votes" do
        expect{patch_vote_up}.not_to change(comment2, :votes_sum)
      end

      it "returns 401 status code" do
        patch_vote_up
        expect(response.status).to eq 401
      end
    end
  end

  describe "GET vote_down" do
    let(:patch_vote_down) do
      patch :vote_down, id: comment2, format: :json
      comment2.reload
    end

    context "when signed in", sign_in: true do
      context "when comment doesn't belong to current user" do
        it "decreases comment's votes" do
          expect{patch_vote_down}.to change(comment2, :votes_sum).by(-1)
        end

        it "sets comment's votes" do
          patch_vote_down
          expect(comment2.reload.votes_sum).to eq -1
        end

        it "assigns @comment" do
          patch_vote_down
          expect(assigns(:parent)).to eq comment2
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

      context "when comment belongs to current user" do
        let(:patch_vote_down) do
          post :vote_down, id: comment, format: :json
        end

        it "doesn't increase comment's votes" do
          expect{patch_vote_down}.not_to change(comment, :votes_sum)
        end

        it "assigns @comment" do
          patch_vote_down
          expect(assigns(:parent)).to eq comment
        end

        it "returns status 403" do
          patch_vote_down
          expect(response.status).to eq 403
        end
      end
    end
    context "when not signed in" do
      it "doesn't increase comment's votes" do
        expect{patch_vote_down}.not_to change(comment2, :votes_sum)
      end

      it "returns 401 status code" do
        patch_vote_down
        expect(response.status).to eq 401
      end
    end
  end
end

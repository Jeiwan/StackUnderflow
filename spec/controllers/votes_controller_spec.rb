require 'rails_helper'

RSpec.describe VotesController, :type => :controller do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:question2) { create(:question, user: user2) }

  user_sign_in

  describe "PATCH #vote_up" do
    let(:patch_vote_up) do
      patch :vote_up, question_id: question2, format: :json
      question2.reload
    end

    context "when signed in", sign_in: true do
      context "when question doesn't belong to current user" do
        it "increases question's votes" do
          expect{patch_vote_up}.to change(question2, :total_votes).by(1)
        end

        it "sets question's votes" do
          patch_vote_up
          expect(question2.total_votes).to eq 1
        end

        it "assigns @question" do
          patch_vote_up
          expect(assigns(:votable)).to eq question2
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

      context "when question belongs to current user" do
        let(:patch_vote_up) do
          post :vote_up, question_id: question, format: :json
        end

        it "doesn't increase question's votes" do
          expect{patch_vote_up}.not_to change(question, :total_votes)
        end

        it "assigns @question" do
          patch_vote_up
          expect(assigns(:votable)).to eq question
        end

        it "returns status 501" do
          patch_vote_up
          expect(response.status).to eq 501
        end
      end
    end

    context "when not signed in" do
      it "doesn't increase question's votes" do
        expect{patch_vote_up}.not_to change(question2, :total_votes)
      end

      it "returns 401 status code" do
        patch_vote_up
        expect(response.status).to eq 401
      end
    end
  end

  describe "GET vote_down" do
    let(:patch_vote_down) do
      patch :vote_down, question_id: question2, format: :json
      question2.reload
    end

    context "when signed in", sign_in: true do
      context "when question doesn't belong to current user" do
        it "decreases question's votes" do
          expect{patch_vote_down}.to change(question2, :total_votes).by(-1)
        end

        it "sets question's votes" do
          patch_vote_down
          expect(question2.reload.total_votes).to eq -1
        end

        it "assigns @question" do
          patch_vote_down
          expect(assigns(:votable)).to eq question2
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

      context "when question belongs to current user" do
        let(:patch_vote_down) do
          post :vote_down, question_id: question, format: :json
        end

        it "doesn't increase question's votes" do
          expect{patch_vote_down}.not_to change(question, :total_votes)
        end

        it "assigns @question" do
          patch_vote_down
          expect(assigns(:votable)).to eq question
        end

        it "returns status 501" do
          patch_vote_down
          expect(response.status).to eq 501
        end
      end
    end
    context "when not signed in" do
      it "doesn't increase question's votes" do
        expect{patch_vote_down}.not_to change(question2, :total_votes)
      end

      it "returns 401 status code" do
        patch_vote_down
        expect(response.status).to eq 401
      end
    end
  end
end

require 'rails_helper'

RSpec.describe VotesController, :type => :controller do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:question) { create(:question, user: user) }
  let(:answer) { create(:answer, question: question, user: user) }
  let(:answer2) { create(:answer, question: question, user: user2) }

  user_sign_in

  describe "PATCH #vote_up" do
    let(:patch_vote_up) do
      patch :vote_up, id: answer2, format: :json
      answer2.reload
    end

    context "when signed in", sign_in: true do
      context "when answer doesn't belong to current user" do
        it "increases answer's votes" do
          expect{patch_vote_up}.to change(answer2, :total_votes).by(1)
        end

        it "sets answer's votes" do
          patch_vote_up
          expect(answer2.total_votes).to eq 1
        end

        it "assigns @answer" do
          patch_vote_up
          expect(assigns(:parent)).to eq answer2
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

      context "when answer belongs to current user" do
        let(:patch_vote_up) do
          post :vote_up, id: answer, format: :json
        end

        it "doesn't increase answer's votes" do
          expect{patch_vote_up}.not_to change(answer, :total_votes)
        end

        it "assigns @answer" do
          patch_vote_up
          expect(assigns(:parent)).to eq answer
        end

        it "returns status 403" do
          patch_vote_up
          expect(response.status).to eq 403
        end
      end
    end

    context "when not signed in" do
      it "doesn't increase answer's votes" do
        expect{patch_vote_up}.not_to change(answer2, :total_votes)
      end

      it "returns 401 status code" do
        patch_vote_up
        expect(response.status).to eq 401
      end
    end
  end

  describe "GET vote_down" do
    let(:patch_vote_down) do
      patch :vote_down, id: answer2, format: :json
      answer2.reload
    end

    context "when signed in", sign_in: true do
      context "when answer doesn't belong to current user" do
        it "decreases answer's votes" do
          expect{patch_vote_down}.to change(answer2, :total_votes).by(-1)
        end

        it "sets answer's votes" do
          patch_vote_down
          expect(answer2.reload.total_votes).to eq -1
        end

        it "assigns @answer" do
          patch_vote_down
          expect(assigns(:parent)).to eq answer2
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

      context "when answer belongs to current user" do
        let(:patch_vote_down) do
          post :vote_down, id: answer, format: :json
        end

        it "doesn't increase answer's votes" do
          expect{patch_vote_down}.not_to change(answer, :total_votes)
        end

        it "assigns @answer" do
          patch_vote_down
          expect(assigns(:parent)).to eq answer
        end

        it "returns status 403" do
          patch_vote_down
          expect(response.status).to eq 403
        end
      end
    end
    context "when not signed in" do
      it "doesn't increase answer's votes" do
        expect{patch_vote_down}.not_to change(answer2, :total_votes)
      end

      it "returns 401 status code" do
        patch_vote_down
        expect(response.status).to eq 401
      end
    end
  end
end

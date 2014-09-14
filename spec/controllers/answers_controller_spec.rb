require 'rails_helper'

RSpec.describe AnswersController, :type => :controller do

	describe "POST #create" do
		let(:user) { create(:user) }
		let(:question) { create(:question, user: user) }
		let(:answer) { create(:answer, question: question) }
		let(:invalid_answer) { create(:invalid_answer, question: question) }

		context "user is logged in" do
			before do
				allow(controller).to receive(:user_signed_in?) { true }
				allow(controller).to receive(:current_user) { user }
			end

			context "with valid data" do
				it "increases a total number of answer" do
					expect{ post :create, question_id: question.id, answer: attributes_for(:answer) }.to change(question.answers, :count).by(1)
				end

				it "increases a total number of user's answer" do
					expect{ post :create, question_id: question.id, answer: attributes_for(:answer) }.to change(user.answers, :count).by(1)
				end

				it "redirects to the question's show page" do
					post :create, question_id: question.id, answer: attributes_for(:answer)
					expect(response).to redirect_to assigns(:question)
				end
			end

			context "with invalid data" do
				it "doesn't increase a total number of answers" do
					expect{ post :create, question_id: question.id, answer: attributes_for(:invalid_answer) }.not_to change(question.answers, :count)
				end

				it "doesn't increase a total number of user's answers" do
					expect{ post :create, question_id: question.id, answer: attributes_for(:invalid_answer) }.not_to change(user.answers, :count)
				end

				it "redirects to the question's show page" do
					post :create, question_id: question.id, answer: attributes_for(:answer)
					expect(response).to redirect_to assigns(:question)
				end
			end
		end

		context "user isn't logged in" do
			before do
				allow(controller).to receive(:user_signed_in?) { false }
				post :create, question_id: question.id, answer: attributes_for(:answer)
				#allow(controller).to receive(:current_user) { user }
			end

			it "redirects to root path with flash message" do
				expect(flash[:danger]).not_to be_nil
				expect(response).to redirect_to root_path
			end
		end
	end
end

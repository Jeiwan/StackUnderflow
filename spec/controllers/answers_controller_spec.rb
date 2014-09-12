require 'rails_helper'

RSpec.describe AnswersController, :type => :controller do

	describe "POST #create" do
		let(:question) { create(:question) }
		let(:answer) { create(:answer, question: question) }
		let(:invalid_answer) { question.create(:invalid_answer) }

		context "with valid data" do
			it "creates a new answer for a question" do
				expect{ post :create, question_id: question.id, answer: attributes_for(:answer) }.to change(question.answers, :count).by(1)
			end

			it "redirects to the question's show page" do
				post :create, question_id: question.id, answer: attributes_for(:answer)
				expect(response).to redirect_to assigns(:question)
			end
		end

		context "with invalid data" do
			it "doesn't create a new answer for a question" do
				expect{ post :create, question_id: question.id, answer: attributes_for(:invalid_answer) }.not_to change(question.answers, :count)
			end

			it "redirects to the question's show page" do
				post :create, question_id: question.id, answer: attributes_for(:answer)
				expect(response).to redirect_to assigns(:question)
			end
		end
	end

end

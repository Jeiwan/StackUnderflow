require 'rails_helper'

RSpec.describe QuestionsController, :type => :controller do
	describe "GET #index" do
		let(:questions) { create_list(:question, 2) }
		before { get :index }

		it "returns a list of questions" do
			expect(assigns(:questions)).to match_array(questions)
		end

		it "render index view" do
			expect(response).to render_template :index
		end
	end

	describe "GET #new" do
		let(:question) { create(:question) }
		before { get :new }

		it "returns a new empty question" do
			expect(assigns(:question)).to be_a_new(Question)
		end

		it "renders new view" do
			expect(response).to render_template :new
		end
	end

	describe "GET #show" do
		let(:question) { create(:question) }
		before { get :show, id: question.id }

		it "returns a question" do
			expect(assigns(:question)).to eq question
		end

		it "renders show view" do
			expect(response).to render_template :show
		end
	end

	describe "POST #create" do
		context "with valid data" do
			let(:question) { create(:question) }

			it "creates a new question" do
				expect{ post :create, question: attributes_for(:question) }.to change(Question, :count).by(1)
			end
			it "redirects to the new question page" do
				post :create, question: attributes_for(:question)
				expect(response).to redirect_to(assigns(:question))
			end
		end

		context "with invalid data" do
			let(:invalid_question) { create(:invalid_question) }

			it "doesn't create a new question" do
				expect{ post :create, question: attributes_for(:invalid_question) }.not_to change(Question, :count)
			end
			it "renders new view" do
				post :create, question: attributes_for(:invalid_question)
				expect(response).to render_template :new
			end
		end
	end
end

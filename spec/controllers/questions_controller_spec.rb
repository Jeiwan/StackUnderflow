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

		context "user is not signed in" do
			before do
				allow(controller).to receive(:user_signed_in?) { false }
				get :new
			end

			it "redirects to root path with flash message" do
				expect(flash[:danger]).not_to be_nil
				expect(response).to redirect_to root_path
			end
		end

		context "user is signed in" do
			before do
				allow(controller).to receive(:user_signed_in?) { true }
				get :new
			end

			it "returns a new empty question" do
				expect(assigns(:question)).to be_a_new(Question)
			end

			it "renders new view" do
				expect(response).to render_template :new
			end
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
		let(:user) { create(:user) }

		before do
			allow(controller).to receive(:user_signed_in?) { true }
			allow(controller).to receive(:current_user) { user }
		end

		context "with valid data" do
			let(:question) { create(:question, user: user) }

			it "increases total questions count" do
				expect{ post :create, question: attributes_for(:question) }.to change(Question, :count).by(1)
			end

			it "increases current user's questions count" do
				expect{ post :create, question: attributes_for(:question) }.to change(user.questions, :count).by(1)
			end

			it "redirects to the new question page" do
				post :create, question: attributes_for(:question)
				expect(response).to redirect_to(assigns(:question))
			end
		end

		context "with invalid data" do
			let(:invalid_question) { create(:invalid_question, user: user) }

			it "doesn't increase total questions count" do
				expect{ post :create, question: attributes_for(:invalid_question) }.not_to change(Question, :count)
			end

			it "doesn't increase current user's questions count" do
				expect{ post :create, question: attributes_for(:invalid_question) }.not_to change(user.questions, :count)
			end

			it "renders new view" do
				post :create, question: attributes_for(:invalid_question)
				expect(response).to render_template :new
			end
		end
	end

	describe "GET #edit" do
		let(:user) { create(:user) }
		let(:question) { create(:question, user: user) }

		context "user is signed in" do
			before do
				allow(controller).to receive(:user_signed_in?) { true }
				allow(controller).to receive(:current_user) { user }
				get :edit, id: question.id
			end

			it "returns a question" do
				expect(assigns(:question)[0]).to eq question
			end

			it "renders edit view" do
				expect(response).to render_template "edit"
			end
		end

		context "user is not signed in" do
			before do
				allow(controller).to receive(:user_signed_in?) { false }
				allow(controller).to receive(:current_user) { user }
				get :edit, id: question.id
			end

			it "redirects to root path" do
				expect(response).to redirect_to root_path
			end
		end

		before do
			allow(controller).to receive(:user_signed_in?) { true }
			allow(controller).to receive(:current_user) { user }
			get :edit, id: question.id
		end

		context "user edits his questions" do
			it "returns a question" do
				expect(assigns(:question)[0]).to eq question
			end

			it "renders edit view" do
				expect(response).to render_template "edit"
			end
		end
		context "user edits not his question" do
			let(:another_question) { create(:question) }
			before { get :edit, id: another_question.id }
			it "redirect to the questions' page" do
				expect(response).to redirect_to another_question
			end
		end
	end

	describe "PUT #update" do
		let(:user) { create(:user) }
		let(:question) { create(:question, user: user) }
		let(:edited_question) do
			edited_question = question.dup
			edited_question.title = "Edited title"
			edited_question
		end

		before do
			allow(controller).to receive(:user_signed_in?) { true }
			allow(controller).to receive(:current_user) { user }
			put :update, id: question.id, question: { title: edited_question.title, body: edited_question.body }
		end

		it "changes question's attribute" do
			expect(Question.find(question.id).title).to eq edited_question.title
		end

		it "redirects to the question page" do
			expect(response).to redirect_to question
		end
	end
end
















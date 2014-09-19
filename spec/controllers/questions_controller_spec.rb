require 'rails_helper'

RSpec.describe QuestionsController, :type => :controller do

	user_sign_in

	describe "GET #index" do
		let(:questions) { create_list(:question, 2) }
		before { get :index }

		it "returns a list of questions" do
			expect(assigns(:questions)).to match_array(questions)
		end

		it "renders index view" do
			expect(response).to render_template :index
		end
	end

	describe "GET #new" do
		let(:question) { create(:question) }
		before { get :new }

		context "user is not signed in" do
			it "redirects to root path" do
				expect(response).to redirect_to new_user_session_path
			end
		end

		context "user is signed in", sign_in: true do
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
		let(:question) { create(:question) }
		let(:attributes) { attributes_for(:question) }
		let(:post_create) do
			-> { post :create, question: attributes }
		end

		context "user is signed in", sign_in: true do
			context "with valid data" do
				it "increases total questions number" do
					expect(post_create).to change(Question, :count).by(1)
				end

				it "increases current user's questions number" do
					expect(post_create).to change(Question, :count).by(1)
				end

				it "redirects to the new question page" do
					post_create.call
					expect(response).to redirect_to(assigns(:question))
				end
			end

			context "with invalid data" do
				let(:attributes) { attributes_for(:question, title: nil, body: nil) }

				it "doesn't increase total questions count" do
					expect(post_create).not_to change(Question, :count)
				end

				it "doesn't increase current user's questions count" do
					expect(post_create).not_to change(Question, :count)
				end

				it "renders new view" do
					post_create.call
					expect(response).to render_template :new
				end
			end
		end

		context "user is not signed in" do
			before { post_create.call }
			it "redirect to the sign in page" do
				expect(response).to redirect_to new_user_session_path
			end
		end

	end

	describe "GET #edit" do
		let(:user) { create(:user) }
		let(:question) { create(:question, user: user) }

		before { get :edit, id: question.id }

		context "user is signed in", sign_in: true do
			it "returns a question" do
				expect(assigns(:question)).to eq question
			end

			it "renders edit view" do
				expect(response).to render_template "edit"
			end
		end

		context "user is not signed in" do
			it "redirects to the sign in page" do
				expect(response).to redirect_to new_user_session_path
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
		let(:put_update) do
			put :update, id: question.id, question: { title: edited_question.title, body: edited_question.body }
		end

		context "user is signed in", sign_in: true do
			before { put_update }

			it "changes question's attribute" do
				expect(question.reload.title).to eq edited_question.title
			end

			it "redirects to the question page" do
				expect(response).to redirect_to question
			end
		end

		context "user is not signed in" do
			before { put_update }

			it "doesn't change question's attribute" do
				expect(question.reload.title).not_to eq edited_question.title
			end

			it "redirects to the sign in page" do
				expect(response).to redirect_to new_user_session_path
			end
		end

	end

	describe "DELETE #destroy" do
		let(:user) { create(:user) }
		let(:question) { create(:question, user: user) }
		let(:delete_destroy) do
			-> { delete :destroy, id: question }
		end

		before { question }

		context "user is signed in", sign_in: true do

			it "removes a question" do
				expect(delete_destroy).to change(Question, :count).by(-1)
			end

			it "redirects to root path" do
				delete_destroy.call
				expect(response).to redirect_to root_path
			end
		end

		context "user is not signed in" do
			it "doesn't delete a question" do
				expect(delete_destroy).not_to change(Question, :count)
			end

			it "redirects to root path" do
				delete_destroy.call
				expect(response).to redirect_to new_user_session_path
			end
		end
	end
end

require 'rails_helper'

RSpec.describe AttachmentsController, :type => :controller do
  describe "DELETE #destroy" do
    let(:user) { create(:user) }
    let(:user2) { create(:user) }
    let(:question) { create(:question, tag_list: "attachments", user: user) }
    let(:question2) { create(:question, tag_list: "attachments", user: user2) }
    let!(:attachment) { create(:attachment, attachable: question, user: user) }
    let!(:attachment2) { create(:attachment, attachable: question2, user: user2) }

    let(:delete_destroy) do
      delete :destroy, id: attachment, format: :json
    end

    user_sign_in

    context "when signed in", sign_in: true do
      context "when attachment belongs to current user" do
        it "removes an attachment" do
          expect{delete_destroy}.to change(Attachment, :count).by(-1)
        end

        it "returns 204 code" do
          delete_destroy
          expect(response.status).to eq 204
        end
      end
      
      context "when attachment doesn't belong to current user" do
        let(:attachment) { attachment2 }
        before { delete_destroy }

        it "doesn't delete the attachment" do
          expect{delete_destroy}.not_to change(Attachment, :count)
        end
        
        it" redirects to root_path" do
          delete_destroy
          expect(response.status).to eq 401
        end
      end
    end

    context "when not signed in" do
      it "doesn't delete the attachment" do
        expect{delete_destroy}.not_to change(Attachment, :count)
      end

      it "returns 401 error" do
        delete_destroy
        expect(response.status).to eq 401
      end
    end
  end
end

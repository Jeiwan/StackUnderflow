class AttachmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_attachment
  before_action :attachment_belongs_to_current_user?

  def destroy
    @attachment.destroy
    render json: :nothing, status: 204
  end

  private
    def find_attachment
      @attachment = Attachment.find(params[:id])
    end

    def attachment_belongs_to_current_user?
      unless @attachment.user == current_user
        render json: :nothing, status: 401
      end
    end
end

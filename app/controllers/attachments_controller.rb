class AttachmentsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_attachment

  respond_to :json, :js

  def destroy
    authorize! :destroy, @attachment
    @attachment.destroy
    respond_with do |format|
      format.html { redirect_to root_path }
      format.json { head :no_content }
      format.js { head :no_content }
    end
  end

  private
    def find_attachment
      @attachment = Attachment.find(params[:id])
    end
end

class Api::V1::UsersController < Api::V1::BaseController
  authorize_resource

  def index
    respond_with @users = User.where('id != ?', current_resource_owner.id), each_serializer: UsersSerializer
  end

  def show
    respond_with @user = User.find_by(username: params[:username])
  end

  def profile
    respond_with current_resource_owner
  end
end

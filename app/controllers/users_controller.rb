class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :find_user

  respond_to :json

  authorize_resource id_param: :username

  def show
  end

  def edit
  end

  def update
    update_resource @user
  end

  def logins
    authorize! :logins, @user
  end

  private
    def user_params
      params.require(:user).permit(:avatar, :username, :email, :website, :age, :location, :full_name)
    end

    def find_user
      @user = User.find_by(username: params[:username])
    end
end

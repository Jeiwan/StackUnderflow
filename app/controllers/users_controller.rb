class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:edit, :update, :logins]
  before_action :find_user

  respond_to :json, :html

  authorize_resource id_param: :username

  def index
    respond_with @users = User.page(params[:page])
  end

  def by_registration
    @users = User.by_registration.page(params[:page])
    render :index
  end

  def alphabetically
    @users = User.alphabetically.page(params[:page])
    render :index
  end

  def show
    respond_with @user
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

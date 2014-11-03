class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :find_user

  respond_to :json, :html

  has_scope :by_reputation, type: :boolean, allow_blank: true
  has_scope :by_registration, type: :boolean, allow_blank: true
  has_scope :alphabetically, type: :boolean, allow_blank: true

  authorize_resource id_param: :username

  def index
    respond_with @users = apply_scopes(User).all
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

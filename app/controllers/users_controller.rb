class UsersController < ApplicationController
  before_action :authenticate_user!, except: [:show, :logins]
  before_action :find_user
  before_action :user_is_current_user?, except: [:show, :logins]

  respond_to :json

  def show
  end

  def edit
  end

  def update
    update_resource @user
  end

  def update_email
    if @user.update(user_params)
      redirect_to root_path
    else
      render "provide_email"
    end
  end

  def logins
  end

  private
    def user_params
      params.require(:user).permit(:avatar, :username, :email, :website, :age, :location, :full_name)
    end

    def find_user
      @user = User.find_by(username: params[:username])
    end

    def user_is_current_user?
      unless @user == current_user
        respond_with do |format|
          format.json { render json: nil, status: 403 }
          format.html { redirect_to @user }
        end
      end
    end
end

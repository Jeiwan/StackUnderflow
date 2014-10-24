class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :auth_provider

  def facebook
  end

  def twitter
  end

  def vkontakte
  end

  private
    
    def auth_provider
      @user = User.find_for_oauth(request.env['omniauth.auth'])
      if @user
        sign_in_and_redirect @user, event: :authentication
        set_flash_message :notice, :success, kind: params[:action].capitalize if is_navigational_format?
      end
    end
end

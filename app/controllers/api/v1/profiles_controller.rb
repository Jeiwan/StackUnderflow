class Api::V1::ProfilesController < Api::V1::BaseController
  skip_authorization_check

  def me
    respond_with current_resource_owner
  end
end

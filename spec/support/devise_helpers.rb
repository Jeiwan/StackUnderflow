module DeviseHelpers
  def user_sign_in
    before(:each) do |example|
      if example.metadata[:sign_in]
        @request.env["devise.mapping"] = Devise.mappings[:user]
        sign_in user
      end
    end
  end
end

module ApiHelper
  def authenticated_headers(user)
    Devise::JWT::TestHelpers.auth_headers({}, user)
  end
end

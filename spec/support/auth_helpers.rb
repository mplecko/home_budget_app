module AuthHelpers
  def auth_headers(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil)[0] # generates a valid JWT token
    { 'Authorization' => "Bearer #{token}", 'Content-Type' => 'application/json' }
  end
end

RSpec.configure do |config|
  config.include AuthHelpers, type: :request
end

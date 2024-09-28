require 'rails_helper'

RSpec.describe 'User Sessions', type: :request do
  let(:user) { create(:user, password: 'password123') }
  let(:valid_login_params) { { user: { email: user.email, password: 'password123' } } }
  let(:invalid_login_params) { { user: { email: user.email, password: 'wrong_password' } } }

  describe 'POST /login' do
    context 'with valid credentials' do
      it 'logs in the user and returns a success message' do
        post '/login', params: valid_login_params
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']['message']).to eq('Logged in successfully.')
      end
    end

    context 'with invalid credentials' do
      it 'returns an error message' do
        post '/login', params: invalid_login_params
        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to eq('Invalid Email or password.')
      end
    end
  end

  describe 'DELETE /logout' do
    context 'with a valid JWT token' do
      it 'logs out the user and returns a success message' do
        post '/login', params: valid_login_params
        token = response.headers['Authorization']

        delete '/logout', headers: { 'Authorization' => token }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('Logged out successfully.')
      end
    end

    context 'without a valid JWT token' do
      it 'returns an unauthorized error message' do
        delete '/logout'
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)['message']).to eq("Couldn't find an active session.")
      end
    end
  end
end

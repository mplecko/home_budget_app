require 'rails_helper'

RSpec.describe 'Users::UsersController', type: :request do
  let(:user) { create :user }
  let(:headers) { authenticate_user(user) }

  describe 'GET /users/users/budget' do
    context 'when the user is authenticated' do
      it 'returns the user budget' do
        get '/users/users/budget', headers: headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ 'budget' => user.budget.to_s })
      end
    end

    context 'when the user is not authenticated' do
      it 'returns a 401 unauthorized error' do
        get '/users/users/budget'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'User Registration', type: :request do
  let(:valid_params) do
    {
      user: {
        email: 'user@example.com',
        password: 'password123',
        password_confirmation: 'password123',
        first_name: 'John',
        last_name: 'Doe'
      }
    }
  end

  let(:invalid_params) do
    {
      user: {
        email: 'invalid_email',
        password: '123',
        password_confirmation: '321',
        first_name: '',
        last_name: ''
      }
    }
  end

  describe 'POST /signup' do
    context 'with valid parameters' do
      it 'registers a new user and returns a success message' do
        post '/signup', params: valid_params, as: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['status']['message']).to eq('Signed up successfully.')
      end
    end

    context 'with invalid parameters' do
      it 'returns an error message' do
        post '/signup', params: invalid_params, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)['status']['message']).to include("User couldn't be created successfully.")
      end
    end
  end
end

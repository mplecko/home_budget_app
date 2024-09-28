require 'swagger_helper'
require 'warden/jwt_auth'

RSpec.describe 'Categories API', type: :request do
  let!(:user) { create(:user) }

  let(:auth_token) do
    Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
  end

  let(:headers) { { 'Authorization' => "Bearer #{auth_token}", 'Content-Type' => 'application/json' } }

  path '/categories' do
    get 'get categories' do
      tags 'Categories'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'categories found' do
        it 'returns a 200 status' do
          get '/categories', headers: headers
          expect(response).to have_http_status(:ok)
        end
      end
    end

    post 'create category' do
      tags 'Categories'
      consumes 'application/json'
      security [Bearer: []]
      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: ['name']
      }

      response '201', 'category created' do
        let(:category) { { name: 'Food' } }

        it 'returns a 201 status' do
          post '/categories', params: category.to_json, headers: headers
          expect(response).to have_http_status(:created)
        end
      end

      response '422', 'invalid request' do
        let(:category) { { name: '' } }

        it 'returns a 422 status' do
          post '/categories', params: category.to_json, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  path '/categories/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ID of the category'

    get 'show category' do
      tags 'Categories'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'category found' do
        let(:category) { create(:category) }
        let(:id) { category.id }

        it 'returns a 200 status' do
          get "/categories/#{id}", headers: headers
          expect(response).to have_http_status(:ok)
        end
      end

      response '404', 'category not found' do
        let(:id) { 0 }

        it 'returns a 404 status' do
          get "/categories/#{id}", headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    put 'update category' do
      tags 'Categories'
      consumes 'application/json'
      security [Bearer: []]
      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        },
        required: ['name']
      }

      response '200', 'category updated' do
        let(:category) { create(:category) }
        let(:id) { category.id }
        let(:category_params) { { name: 'Updated Category' } }

        it 'returns a 200 status' do
          put "/categories/#{id}", params: category_params.to_json, headers: headers
          expect(response).to have_http_status(:ok)
        end
      end

      response '422', 'invalid request' do
        let(:category) { create(:category) }
        let(:id) { category.id }
        let(:category_params) { { name: '' } }

        it 'returns a 422 status' do
          put "/categories/#{id}", params: category_params.to_json, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      response '404', 'category not found' do
        let(:id) { 0 }

        it 'returns a 404 status' do
          put "/categories/#{id}", params: { name: 'Updated Category' }.to_json, headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    delete 'delete category' do
      tags 'Categories'
      security [Bearer: []]

      response '204', 'category deleted' do
        let(:category) { create(:category) }
        let(:id) { category.id }

        it 'returns a 204 status' do
          delete "/categories/#{id}", headers: headers
          expect(response).to have_http_status(:no_content)
        end
      end

      response '404', 'category not found' do
        let(:id) { 0 }

        it 'returns a 404 status' do
          delete "/categories/#{id}", headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'Categories', type: :request do
  let(:user) { create(:user) }
  let(:headers) { authenticate_user(user) }
  let(:category_params) { { category: { name: 'New Category' } } }
  let(:category) { create(:category) }

  describe 'GET /categories' do
    it 'returns all categories' do
      create(:category, name: 'Category 1')
      create(:category, name: 'Category 2')

      get '/categories', headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(2)
    end

    it 'returns unauthorized when user is not authenticated' do
      get '/categories'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /categories/:id' do
    it 'returns the category' do
      get "/categories/#{category.id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['name']).to eq(category.name)
    end

    it 'returns a not found message if the category does not exist' do
      get '/categories/999', headers: headers
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to include('Not Found')
    end

    it 'returns unauthorized when user is not authenticated' do
      get "/categories/#{category.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'POST /categories' do
    it 'creates a new category with valid parameters' do
      expect {
        post '/categories', params: category_params, headers: headers
      }.to change(Category, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['name']).to eq('New Category')
    end

    it 'returns unprocessable entity status with invalid parameters' do
      post '/categories', params: { category: { name: '' } }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to include("Name can't be blank")
    end

    it 'does not allow duplicate category names' do
      create(:category, name: 'Duplicate Category')
      post '/categories', params: { category: { name: 'Duplicate Category' } }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to include('Name has already been taken')
    end

    it 'returns unauthorized when user is not authenticated' do
      post '/categories', params: category_params
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'PATCH /categories/:id' do
    it 'updates the category with valid parameters' do
      patch "/categories/#{category.id}", params: { category: { name: 'Updated Category' } }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['name']).to eq('Updated Category')
    end

    it 'returns unprocessable entity status with invalid parameters' do
      patch "/categories/#{category.id}", params: { category: { name: '' } }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to include("Name can't be blank")
    end

    it 'returns a not found message if the category does not exist' do
      patch '/categories/999', params: { category: { name: 'Non-existent Category' } }, headers: headers
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to include('Not Found')
    end

    it 'returns unauthorized when user is not authenticated' do
      patch "/categories/#{category.id}", params: { category: { name: 'Updated Category' } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /categories/:id' do
    it 'does not delete the category if it has associated expenses' do
      create(:expense, category: category)

      delete "/categories/#{category.id}", headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to include('Cannot delete category with associated expenses')
    end

    it 'deletes the category if it has no associated expenses' do
      category_to_delete = create(:category)
      expect {
        delete "/categories/#{category_to_delete.id}", headers: headers
      }.to change(Category, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it 'returns a not found message when the category does not exist' do
      delete '/categories/999', headers: headers
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to include('Not Found')
    end

    it 'returns unauthorized when user is not authenticated' do
      delete "/categories/#{category.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

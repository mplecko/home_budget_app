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
  end

  describe 'DELETE /categories/:id' do
    it 'deletes the category' do
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
  end
end

require 'rails_helper'

RSpec.describe 'Expenses', type: :request do
  let(:user) { create(:user, budget: 1000.0) }
  let(:headers) { authenticate_user(user) }
  let(:category) { create(:category) }
  let(:expense_params) { { expense: { description: 'Grocery Shopping', amount: 100.0, date: Date.today, category_id: category.id } } }

  describe 'GET /expenses' do
    it 'returns all expenses for the current user' do
      create(:expense, user: user, category: category, amount: 50.0)
      create(:expense, user: user, category: category, amount: 100.0)

      get '/expenses', headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(2)
    end
  end

  describe 'GET /expenses/:id' do
    let(:expense) { create(:expense, user: user, category: category) }

    it 'returns the expense' do
      get "/expenses/#{expense.id}", headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['description']).to eq(expense.description)
    end

    it 'returns a not found message if the expense does not exist' do
      get '/expenses/999', headers: headers
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to include('Not Found')
    end
  end

  describe 'POST /expenses' do
    it 'creates a new expense with valid parameters' do
      expect {
        post '/expenses', params: expense_params, headers: headers
      }.to change(Expense, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(JSON.parse(response.body)['remaining_budget']).to eq('900.0')
    end

    it 'returns unprocessable entity status with invalid parameters' do
      post '/expenses', params: { expense: { description: '', amount: '', date: '', category_id: '' } }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to include("Amount can't be blank", "Date can't be blank")
    end
  end

  describe 'DELETE /expenses/:id' do
    let!(:expense) { create(:expense, user: user, category: category) }

    it 'deletes the expense' do
      expect {
        delete "/expenses/#{expense.id}", headers: headers
      }.to change(Expense, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it 'returns a not found message when the expense does not exist (DELETE)' do
      delete '/expenses/999', headers: headers
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to include('Not Found')
    end
  end
end

require 'rails_helper'

RSpec.describe 'Expenses', type: :request do
  let(:user) { create(:user, budget: 1000.0) }
  let(:headers) { authenticate_user(user) }
  let(:category) { create(:category) }
  let(:expense_params) { { expense: { description: 'Grocery Shopping', amount: 100.0, date: Date.today, category_id: category.id } } }
  let(:expense) { create(:expense, user: user, category: category) }

  describe 'GET /expenses' do
    it 'returns all expenses for the current user' do
      create(:expense, user: user, category: category, amount: 50.0)
      create(:expense, user: user, category: category, amount: 100.0)

      get '/expenses', headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(2)
    end

    it 'returns unauthorized when user is not authenticated' do
      get '/expenses'
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /expenses/:id' do
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

    it 'returns unauthorized when user is not authenticated' do
      get "/expenses/#{expense.id}"
      expect(response).to have_http_status(:unauthorized)
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

    it 'returns unauthorized when user is not authenticated' do
      post '/expenses', params: expense_params
      expect(response).to have_http_status(:unauthorized)
    end

    it 'handles negative amount gracefully' do
      post '/expenses', params: { expense: { description: 'Refund', amount: -50.0, date: Date.today, category_id: category.id } }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to include('Amount must be greater than 0')
    end
  end

  describe 'PATCH /expenses/:id' do
    it 'updates the expense with valid parameters' do
      patch "/expenses/#{expense.id}", params: { expense: { description: 'Updated Expense', amount: 150.0 } }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['expense']['description']).to eq('Updated Expense')
    end

    it 'returns unprocessable entity status with invalid parameters' do
      patch "/expenses/#{expense.id}", params: { expense: { amount: '' } }, headers: headers
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['errors']).to include("Amount can't be blank")
    end

    it 'returns a not found message if the expense does not exist' do
      patch '/expenses/999', params: { expense: { description: 'Non-existent Expense' } }, headers: headers
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to include('Not Found')
    end

    it 'returns unauthorized when user is not authenticated' do
      patch "/expenses/#{expense.id}", params: { expense: { description: 'Updated Expense', amount: 150.0 } }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'DELETE /expenses/:id' do
    it 'deletes the expense' do
      expense_to_delete = create(:expense, user: user, category: category)
      expect {
        delete "/expenses/#{expense_to_delete.id}", headers: headers
      }.to change(Expense, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it 'returns a not found message when the expense does not exist' do
      delete '/expenses/999', headers: headers
      expect(response).to have_http_status(:not_found)
      expect(JSON.parse(response.body)['error']).to include('Not Found')
    end

    it 'returns unauthorized when user is not authenticated' do
      delete "/expenses/#{expense.id}"
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /expenses/date_range' do
    let(:start_date) { Date.today - 10 }
    let(:end_date) { Date.today }

    it 'returns expenses within the date range' do
      create(:expense, user: user, category: category, amount: 50.0, date: start_date)
      create(:expense, user: user, category: category, amount: 100.0, date: end_date)

      get '/expenses/date_range', params: { start_date: start_date, end_date: end_date }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['total_expenses_in_given_range']).to eq('150.0')
    end

    it 'returns unprocessable entity when start date is after end date' do
      get '/expenses/date_range', params: { start_date: end_date, end_date: start_date }, headers: headers
      expect(response).to have_http_status(:bad_request)
      expect(JSON.parse(response.body)['error']).to include('invalid date')
    end

    it 'returns unauthorized when user is not authenticated' do
      get '/expenses/date_range', params: { start_date: start_date, end_date: end_date }
      expect(response).to have_http_status(:unauthorized)
    end
  end
end

require 'rails_helper'

RSpec.describe 'Expenses', type: :request do
  let(:user) { create :user }
  let(:headers) { authenticate_user(user) }
  let(:category1) { create(:category) }
  let(:category2) { create(:category) }
  let(:expense_params) { { expense: { description: 'Grocery Shopping', amount: 100.0, date: Date.today, category_id: category1.id } } }
  let(:expense) { create(:expense, user: user, category: category1) }

  describe 'GET /expenses' do
    it 'returns all expenses for the current user' do
      create(:expense, user: user, category: category1, amount: 50.0)
      create(:expense, user: user, category: category1, amount: 100.0)

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
      post '/expenses', params: { expense: { description: 'Refund', amount: -50.0, date: Date.today, category_id: category1.id } }, headers: headers
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
      expense_to_delete = create(:expense, user: user, category: category1)
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

  describe 'GET /expenses/filter' do
    before do
      create(:expense, user: user, category: category1, amount: 50.0, date: Date.today - 7.days)
      create(:expense, user: user, category: category1, amount: 100.0, date: Date.today - 1.day)
      create(:expense, user: user, category: category2, amount: 150.0, date: Date.today)
    end

    context 'when filtering by date range' do
      it 'returns expenses within the date range' do
        get '/expenses/filter', params: { start_date: Date.today - 7.days, end_date: Date.today }, headers: headers
        expect(response).to have_http_status(:ok)
        expenses = JSON.parse(response.body)['expenses']
        expect(expenses.size).to eq(3)
      end

      it 'returns an error when start date is after end date' do
        get '/expenses/filter', params: { start_date: Date.today, end_date: Date.today - 7.days }, headers: headers
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to include('Start date must be before or equal to end date')
      end

      it 'returns an error when start date or end date is missing' do
        get '/expenses/filter', params: { start_date: Date.today }, headers: headers
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to include('param is missing or the value is empty: end_date')
      end
    end

    context 'when filtering by price range' do
      it 'returns expenses within the price range' do
        get '/expenses/filter', params: { min_price: 50.0, max_price: 150.0 }, headers: headers
        expect(response).to have_http_status(:ok)
        expenses = JSON.parse(response.body)['expenses']
        expect(expenses.size).to eq(3)
      end

      it 'returns an error when min price is greater than max price' do
        get '/expenses/filter', params: { min_price: 150.0, max_price: 50.0 }, headers: headers
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to include('Minimum price must be less than or equal to maximum price')
      end

      it 'returns an error when min price or max price is missing' do
        get '/expenses/filter', params: { min_price: 50.0 }, headers: headers
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)['error']).to include('param is missing or the value is empty: max_price')
      end
    end

    context 'when filtering by category' do
      it 'returns expenses in the specified category' do
        get '/expenses/filter', params: { category_id: category1.id }, headers: headers
        expect(response).to have_http_status(:ok)
        expenses = JSON.parse(response.body)['expenses']
        expect(expenses.size).to eq(2)
      end

      it 'returns an error when the category does not exist' do
        get '/expenses/filter', params: { category_id: 999 }, headers: headers
        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)['error']).to include('Not Found')
      end
    end

    context 'when combining filters' do
      it 'returns expenses matching all filters' do
        get '/expenses/filter', params: { start_date: Date.today - 7.days, end_date: Date.today, min_price: 50.0, max_price: 100.0, category_id: category1.id }, headers: headers
        expect(response).to have_http_status(:ok)
        expenses = JSON.parse(response.body)['expenses']
        expect(expenses.size).to eq(2)
      end
    end
  end
end

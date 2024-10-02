require 'swagger_helper'
require 'warden/jwt_auth'

RSpec.describe 'Expenses API', type: :request do
  let!(:user) { create(:user) }
  let!(:category1) { create(:category, name: 'Food') }
  let!(:category2) { create(:category, name: 'Transport') }
  let(:auth_token) do
    Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
  end
  let(:headers) { { 'Authorization' => "Bearer #{auth_token}", 'Content-Type' => 'application/json' } }

  path '/expenses' do
    get 'Retrieves all expenses' do
      tags 'Expenses'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'expenses found' do
        schema type: :array, items: { '$ref' => '#/components/schemas/expense' }

        it 'returns a 200 status' do
          get '/expenses', headers: headers
          expect(response).to have_http_status(:ok)
        end
      end
    end

    post 'Creates a new expense' do
      tags 'Expenses'
      consumes 'application/json'
      security [Bearer: []]
      parameter name: :expense, in: :body, schema: {
        type: :object,
        properties: {
          description: { type: :string },
          amount: { type: :number },
          date: { type: :string, format: :date },
          category_id: { type: :integer }
        },
        required: ['description', 'amount', 'date', 'category_id']
      }

      response '201', 'expense created' do
        let(:expense) { { description: 'Grocery shopping', amount: 50.5, date: '2024-01-01', category_id: category1.id } }

        it 'returns a 201 status' do
          post '/expenses', params: expense.to_json, headers: headers
          expect(response).to have_http_status(:created)
        end
      end

      response '422', 'invalid request' do
        let(:expense) { { description: '' } }

        it 'returns a 422 status' do
          post '/expenses', params: expense.to_json, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  path '/expenses/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ID of the expense'

    get 'show expense' do
      tags 'Expenses'
      produces 'application/json'
      security [Bearer: []]

      response '200', 'expense found' do
        let(:expense) { create(:expense, user: user, category: category1) }
        let(:id) { expense.id }

        it 'returns a 200 status' do
          get "/expenses/#{id}", headers: headers
          expect(response).to have_http_status(:ok)
        end
      end

      response '404', 'expense not found' do
        let(:id) { 0 }

        it 'returns a 404 status' do
          get "/expenses/#{id}", headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    put 'update expense' do
      tags 'Expenses'
      consumes 'application/json'
      security [Bearer: []]
      parameter name: :expense, in: :body, schema: {
        type: :object,
        properties: {
          description: { type: :string },
          amount: { type: :number },
          date: { type: :string, format: :date },
          category_id: { type: :integer }
        },
        required: ['description', 'amount', 'date', 'category_id']
      }

      response '200', 'expense updated' do
        let(:expense) { create(:expense, user: user, category: category1) }
        let(:id) { expense.id }
        let(:expense_params) { { description: 'Updated expense', amount: 30.0, date: '2024-01-05', category_id: category1.id } }

        it 'returns a 200 status' do
          put "/expenses/#{id}", params: expense_params.to_json, headers: headers
          expect(response).to have_http_status(:ok)
        end
      end

      response '422', 'invalid request' do
        let(:expense) { create(:expense, user: user, category: category1) }
        let(:id) { expense.id }
        let(:expense_params) { { description: '', amount: 30.0, date: '2024-01-05', category_id: category1.id } }

        it 'returns a 422 status' do
          put "/expenses/#{id}", params: expense_params.to_json, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      response '404', 'expense not found' do
        let(:id) { 0 }

        it 'returns a 404 status' do
          put "/expenses/#{id}", params: { description: 'Updated expense', amount: 30.0, date: '2024-01-05', category_id: category1.id }.to_json, headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    delete 'delete expense' do
      tags 'Expenses'
      security [Bearer: []]

      response '204', 'expense deleted' do
        let(:expense) { create(:expense, user: user, category: category1) }
        let(:id) { expense.id }

        it 'returns a 204 status' do
          delete "/expenses/#{id}", headers: headers
          expect(response).to have_http_status(:no_content)
        end
      end

      response '404', 'expense not found' do
        let(:id) { 0 }

        it 'returns a 404 status' do
          delete "/expenses/#{id}", headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end

  path '/expenses/filter' do
    get 'Filters expenses based on various parameters' do
      tags 'Expenses'
      produces 'application/json'
      security [Bearer: []]
      parameter name: :start_date, in: :query, type: :string, format: :date, description: 'Start date for filtering'
      parameter name: :end_date, in: :query, type: :string, format: :date, description: 'End date for filtering'
      parameter name: :min_price, in: :query, type: :number, description: 'Minimum price for filtering'
      parameter name: :max_price, in: :query, type: :number, description: 'Maximum price for filtering'
      parameter name: :category_id, in: :query, type: :integer, description: 'Category ID for filtering'

      let!(:expense1) { create(:expense, user: user, category: category1, amount: 50.0, date: Date.today - 7.days) }
      let!(:expense2) { create(:expense, user: user, category: category1, amount: 100.0, date: Date.today - 1.day) }
      let!(:expense3) { create(:expense, user: user, category: category2, amount: 150.0, date: Date.today) }

      # Success responses:
      response '200', 'expenses filtered by date range' do
        schema type: :array, items: { '$ref' => '#/components/schemas/expense' }

        let(:start_date) { (Date.today - 7.days).to_s }
        let(:end_date) { Date.today.to_s }

        it 'returns filtered expenses' do
          get '/expenses/filter', params: { start_date: start_date, end_date: end_date }, headers: headers
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['expenses'].size).to eq(3)
        end
      end

      # Error: invalid date range
      response '400', 'invalid date range or format' do
        schema type: :object, properties: {
          error: { type: :string, example: 'Start date must be before or equal to end date' }
        }

        let(:start_date) { Date.today.to_s }
        let(:end_date) { (Date.today - 7.days).to_s }

        it 'returns a bad request for invalid date range' do
          get '/expenses/filter', params: { start_date: start_date, end_date: end_date }, headers: headers
          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)['error']).to include('Start date must be before or equal to end date')
        end

        it 'returns a bad request for invalid date format' do
          get '/expenses/filter', params: { start_date: 'invalid_date', end_date: Date.today.to_s }, headers: headers
          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)['error']).to include('Invalid date format for start_date')
        end
      end

      response '200', 'expenses filtered by price range' do
        schema type: :array, items: { '$ref' => '#/components/schemas/expense' }

        let(:min_price) { 50.0 }
        let(:max_price) { 150.0 }

        it 'returns filtered expenses' do
          get '/expenses/filter', params: { min_price: min_price, max_price: max_price }, headers: headers
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['expenses'].size).to eq(3)
        end
      end

      response '400', 'min price greater than max price' do
        schema type: :object, properties: {
          error: { type: :string, example: 'Minimum price must be less than or equal to maximum price' }
        }

        let(:min_price) { 150.0 }
        let(:max_price) { 50.0 }

        it 'returns a bad request for invalid price range' do
          get '/expenses/filter', params: { min_price: min_price, max_price: max_price }, headers: headers
          expect(response).to have_http_status(:bad_request)
          expect(JSON.parse(response.body)['error']).to include('Minimum price must be less than or equal to maximum price')
        end
      end

      response '200', 'expenses filtered by category' do
        schema type: :array, items: { '$ref' => '#/components/schemas/expense' }

        let(:category_id) { category1.id }

        it 'returns filtered expenses' do
          get '/expenses/filter', params: { category_id: category_id }, headers: headers
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)['expenses'].size).to eq(2)
        end
      end

      response '404', 'category not found' do
        schema type: :object, properties: {
          error: { type: :string, example: 'Category not found' }
        }

        let(:category_id) { 999 }

        it 'returns a 404 status for non-existent category' do
          get '/expenses/filter', params: { category_id: category_id }, headers: headers
          expect(response).to have_http_status(:not_found)
          expect(JSON.parse(response.body)['error']).to include('Not Found')
        end
      end
    end
  end
end

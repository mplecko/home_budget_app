require 'swagger_helper'
require 'warden/jwt_auth'

RSpec.describe 'Expenses API', type: :request do
  let!(:user) { create(:user) }
  let!(:category) { create(:category, name: 'Food') }
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
        let(:expense) { { description: 'Grocery shopping', amount: 50.5, date: '2024-01-01', category_id: category.id } }

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
        let(:expense) { create(:expense, user: user, category: category) }
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
        let(:expense) { create(:expense, user: user, category: category) }
        let(:id) { expense.id }
        let(:expense_params) { { description: 'Updated expense', amount: 30.0, date: '2024-01-05', category_id: category.id } }

        it 'returns a 200 status' do
          put "/expenses/#{id}", params: expense_params.to_json, headers: headers
          expect(response).to have_http_status(:ok)
        end
      end

      response '422', 'invalid request' do
        let(:expense) { create(:expense, user: user, category: category) }
        let(:id) { expense.id }
        let(:expense_params) { { description: '', amount: 30.0, date: '2024-01-05', category_id: category.id } }

        it 'returns a 422 status' do
          put "/expenses/#{id}", params: expense_params.to_json, headers: headers
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      response '404', 'expense not found' do
        let(:id) { 0 }

        it 'returns a 404 status' do
          put "/expenses/#{id}", params: { description: 'Updated expense', amount: 30.0, date: '2024-01-05', category_id: category.id }.to_json, headers: headers
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    delete 'delete expense' do
      tags 'Expenses'
      security [Bearer: []]

      response '204', 'expense deleted' do
        let(:expense) { create(:expense, user: user, category: category) }
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

  path '/expenses/date_range' do
    get 'Retrieves expenses within a date range' do
      tags 'Expenses'
      produces 'application/json'
      security [Bearer: []]
      parameter name: :start_date, in: :query, type: :string, format: :date, description: 'Start date of the range'
      parameter name: :end_date, in: :query, type: :string, format: :date, description: 'End date of the range'

      response '200', 'expenses within date range found' do
        let(:start_date) { '2024-01-01' }
        let(:end_date) { '2024-01-31' }

        it 'returns a 200 status' do
          get "/expenses/date_range?start_date=#{start_date}&end_date=#{end_date}", headers: headers
          expect(response).to have_http_status(:ok)
        end
      end

      response '400', 'invalid date range' do
        let(:start_date) { '2024-01-01' }
        let(:end_date) { '' }

        it 'returns a 400 status' do
          get "/expenses/date_range?start_date=#{start_date}&end_date=#{end_date}", headers: headers
          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'Users::MaximumBudgetsController', type: :request do
  let(:user) { create(:user) }
  let(:headers) { authenticated_headers(user) }

  describe 'GET /users/maximum_budgets' do
    context 'when the user is authenticated' do
      it 'returns the user maximum_budget' do
        get '/users/maximum_budgets', headers: headers

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq({ 'maximum_budget' => user.maximum_budget.to_s })
      end
    end

    context 'when the user is not authenticated' do
      it 'returns a 401 unauthorized error' do
        get '/users/maximum_budgets'

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe 'PATCH /users/maximum_budget' do
    let(:new_maximum_budget) { 2000.0 }

    context 'when the user is authenticated' do
      context 'with valid parameters' do
        it 'updates the maximum budget and returns the updated budget' do
          patch '/users/maximum_budgets',
                params: { maximum_budget: new_maximum_budget },
                headers: headers

          user.reload
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq({
            'message' => 'Maximum budget updated successfully',
            'maximum_budget' => user.maximum_budget.to_s
          })
          expect(user.maximum_budget).to eq(new_maximum_budget)
        end

        it 'successfully updates with a large maximum_budget value' do
          large_budget = 1_000_000.0
          patch '/users/maximum_budgets', params: { maximum_budget: large_budget }, headers: headers

          user.reload
          expect(response).to have_http_status(:ok)
          expect(JSON.parse(response.body)).to eq({
            'message' => 'Maximum budget updated successfully',
            'maximum_budget' => user.maximum_budget.to_s
          })
          expect(user.maximum_budget).to eq(large_budget)
        end
      end

      context 'with invalid parameters' do
        it 'returns an error when maximum_budget is not provided' do
          patch '/users/maximum_budgets', headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({
            'errors' => ['Maximum budget must be present and greater than 0']
          })
        end

        it 'returns an error when maximum_budget is negative' do
          patch '/users/maximum_budgets', params: { maximum_budget: -500 }, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({
            'errors' => ['Maximum budget must be present and greater than 0']
          })
        end

        it 'does not update maximum_budget if parameters are invalid' do
          original_budget = user.maximum_budget
          patch '/users/maximum_budgets', params: { maximum_budget: -100 }, headers: headers

          user.reload
          expect(user.maximum_budget).to eq(original_budget)
        end

        it 'returns an error when maximum_budget is a string' do
          patch '/users/maximum_budgets', params: { maximum_budget: 'invalid_string' }, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({
            'errors' => ['Maximum budget must be present and greater than 0']
          })
        end

        it 'returns an error when maximum_budget is a symbol' do
          patch '/users/maximum_budgets', params: { maximum_budget: :invalid_symbol }, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({
            'errors' => ['Maximum budget must be present and greater than 0']
          })
        end

        it 'returns an error when maximum_budget is explicitly set to nil' do
          patch '/users/maximum_budgets', params: { maximum_budget: nil }, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(JSON.parse(response.body)).to eq({
            'errors' => ['Maximum budget must be present and greater than 0']
          })
        end
      end
    end

    context 'when the user is not authenticated' do
      it 'returns a 401 unauthorized error' do
        patch '/users/maximum_budgets', params: { maximum_budget: new_maximum_budget }

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

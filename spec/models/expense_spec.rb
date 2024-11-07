require 'rails_helper'

RSpec.describe Expense, type: :model do
  let(:user) { create(:user, remaining_budget: 1000.0) }
  let(:category) { create(:category) }
  let(:expense) { build(:expense, user: user, category: category) }

  describe 'validations' do
    it 'is valid with a description, amount, date, user, and category' do
      expect(expense).to be_valid
    end

    it 'is invalid without an amount' do
      expense.amount = nil
      expect(expense).not_to be_valid
      expect(expense.errors[:amount]).to include("can't be blank")
    end

    it 'is invalid without a date' do
      expense.date = nil
      expect(expense).not_to be_valid
      expect(expense.errors[:date]).to include("can't be blank")
    end

    it 'is invalid if the date is in the future' do
      expense.date = Date.tomorrow
      expect(expense).not_to be_valid
      expect(expense.errors[:date]).to include('cannot be in the future')
    end

    it 'is invalid if the amount is zero or negative' do
      expense.amount = 0
      expect(expense).not_to be_valid
      expect(expense.errors[:amount]).to include('must be greater than 0')

      expense.amount = -100
      expect(expense).not_to be_valid
      expect(expense.errors[:amount]).to include('must be greater than 0')
    end

    it 'is invalid if the date is updated to a future date' do
      expense.date = Date.today
      expense.save

      expense.date = Date.tomorrow
      expect(expense).not_to be_valid
      expect(expense.errors[:date]).to include('cannot be in the future')
    end
  end

  describe 'callbacks' do
    it 'deducts the amount from the user’s budget after create' do
      expense.save
      expect(user.remaining_budget).to eq(950.0)
    end

    it 'updates user remaining budget after destroy' do
      expense.save
      initial_budget = user.remaining_budget

      expense.destroy
      expect(user.remaining_budget).to eq(initial_budget + expense.amount)
    end
  end

  describe 'scopes' do
    before do
      @expense1 = create(:expense, user: user, category: category, date: Date.today.beginning_of_month, amount: 50)
      @expense2 = create(:expense, user: user, category: category, date: [Date.today.end_of_month, Date.today].min, amount: 150)
      @expense3 = create(:expense, user: user, category: category, date: Date.today - 1.month, amount: 300)
    end

    describe '.within_date_range' do
      it 'returns expenses within the specified date range' do
        start_date = Date.today.beginning_of_month
        end_date = Date.today.end_of_month

        expenses_in_range = Expense.within_date_range(start_date, end_date)
        expect(expenses_in_range).to include(@expense1, @expense2)
        expect(expenses_in_range).not_to include(@expense3)
      end
    end

    describe '.current_month' do
      it 'returns expenses from the current month' do
        current_month_expenses = Expense.current_month
        expect(current_month_expenses).to include(@expense1, @expense2)
        expect(current_month_expenses).not_to include(@expense3)
      end
    end

    describe '.within_price_range' do
      it 'returns expenses within the specified price range' do
        min_price = 100
        max_price = 200

        expenses_in_price_range = Expense.within_price_range(min_price, max_price)
        expect(expenses_in_price_range).to include(@expense2)
        expect(expenses_in_price_range).not_to include(@expense1, @expense3)
      end

      it 'returns expenses with amount greater than or equal to min price when max price is not provided' do
        min_price = 100

        expenses_in_price_range = Expense.within_price_range(min_price, Float::INFINITY)
        expect(expenses_in_price_range).to include(@expense2, @expense3)
        expect(expenses_in_price_range).not_to include(@expense1)
      end
    end
  end
end

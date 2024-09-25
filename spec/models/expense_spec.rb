require 'rails_helper'

RSpec.describe Expense, type: :model do
  let(:user) { create(:user, budget: 1000.0) }
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

    it 'is invalid with an amount less than or equal to 0' do
      expense.amount = 0
      expect(expense).not_to be_valid
      expect(expense.errors[:amount]).to include('must be greater than 0')
    end

    it 'is invalid without a date' do
      expense.date = nil
      expect(expense).not_to be_valid
      expect(expense.errors[:date]).to include("can't be blank")
    end
  end

  describe 'callbacks' do
    it 'deducts the amount from the user’s budget after create' do
      expense.save
      expect(user.budget).to eq(950.0)
    end
  end
end

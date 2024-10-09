require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'is not valid without a first name' do
      user.first_name = nil
      expect(user).not_to be_valid
      expect(user.errors[:first_name]).to include("can't be blank")
    end

    it 'is not valid without a last name' do
      user.last_name = nil
      expect(user).not_to be_valid
      expect(user.errors[:last_name]).to include("can't be blank")
    end

    it 'is not valid without an email' do
      user.email = nil
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is not valid with a duplicate email' do
      user_with_same_email = build(:user, email: user.email)
      expect(user_with_same_email).not_to be_valid
      expect(user_with_same_email.errors[:email]).to include('has already been taken')
    end

    it 'is valid with a unique email' do
      another_user = build(:user, email: 'unique@example.com')
      expect(another_user).to be_valid
    end
  end

  describe 'associations' do
    it { should have_many(:expenses).dependent(:destroy) }
  end

  describe 'callbacks' do
    it 'sets initial budget before creation' do
      new_user = build(:user)
      new_user.save
      expect(new_user.budget).to eq(1000.00)
      expect(new_user.budget_reset_date).to eq(Date.today.next_month.beginning_of_month)
    end
  end

  describe '#calculate_budget' do
    it 'calculates the remaining budget correctly' do
      create(:expense, user: user, amount: 200.0)
      create(:expense, user: user, amount: 300.0)

      user.calculate_budget
      expect(user.budget).to eq(1000 - 200 - 300)
    end

    it 'does not affect budget if no expenses exist' do
      user.calculate_budget
      expect(user.budget).to eq(1000.0)
    end
  end

  describe '.reset_all_budgets' do
    it 'resets budget for all users when needed' do
      create(:expense, user: user, amount: 200.0)
      user.update(budget_reset_date: Date.yesterday)
      user.calculate_budget

      User.reset_all_budgets
      user.reload

      expect(user.budget).to eq(1000.00)
      expect(user.budget_reset_date).to eq(Date.today.next_month.beginning_of_month)
    end

    it 'does not reset budget if reset date has not passed' do
      create(:expense, user: user, amount: 200.0)
      user.update(budget_reset_date: Date.today + 2.days)
      user.calculate_budget

      budget_before_reset = user.budget

      User.reset_all_budgets
      user.reload

      expect(user.budget).to eq(budget_before_reset)
    end
  end

  describe '.reset_budget_if_needed' do
    it 'resets budget if the reset date has passed' do
      create(:expense, user: user, amount: 200.0)
      user.update(budget_reset_date: Date.yesterday)
      user.calculate_budget

      User.reset_budget_if_needed(user)
      user.reload

      expect(user.budget).to eq(1000.00)
      expect(user.budget_reset_date).to eq(Date.today.next_month.beginning_of_month)
    end

    it 'does not reset budget if the reset date has not passed' do
      create(:expense, user: user, amount: 200.0)
      user.update(budget_reset_date: Date.today + 2.days)
      user.calculate_budget

      budget_before_reset = user.budget

      User.reset_budget_if_needed(user)
      user.reload

      expect(user.budget).to eq(budget_before_reset)
    end
  end
end

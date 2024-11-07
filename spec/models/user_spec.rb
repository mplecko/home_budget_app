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
    it 'sets remaining budget reset date' do
      new_user = build(:user)
      new_user.save
      expect(new_user.remaining_budget).to eq(1000.00)
      expect(new_user.maximum_budget).to eq(1000.00)
      expect(new_user.remaining_budget_reset_date).to eq(Date.today.next_month.beginning_of_month)
    end
  end

  describe '#calculate_remaining_budget' do
    it 'calculates the remaining budget correctly based on maximum_budget' do
      create(:expense, user: user, amount: 200.0)
      create(:expense, user: user, amount: 300.0)

      user.calculate_remaining_budget
      expect(user.remaining_budget).to eq(user.maximum_budget - 200 - 300)
    end

    it 'does not affect remaining_budget if no expenses exist' do
      user.calculate_remaining_budget
      expect(user.remaining_budget).to eq(user.maximum_budget)
    end
  end

  describe '#update_maximum_budget' do
    it 'updates the maximum_budget' do
      user.update_maximum_budget(2000.0)
      expect(user.maximum_budget).to eq(2000.0)
    end

    it 'recalculates remaining_budget when maximum_budget is updated' do
      create(:expense, user: user, amount: 100.0, date: Date.today.beginning_of_month)

      user.update_maximum_budget(2000.0)
      user.reload

      expected_remaining_budget = 2000.0 - 100.0
      expect(user.remaining_budget).to eq(expected_remaining_budget)
      expect(user.maximum_budget).to eq(2000.0)
    end
  end

  describe '#reset_remaining_budget_if_needed' do
    it 'resets remaining_budget by subtracting monthly expenses from maximum_budget if the reset date has passed' do
      create(:expense, user: user, amount: 200.0, date: Date.today.beginning_of_month + 1.day)
      create(:expense, user: user, amount: 150.0, date: Date.today.last_month.end_of_month)

      user.update(remaining_budget_reset_date: Date.yesterday)
      user.calculate_remaining_budget

      user.reset_remaining_budget_if_needed
      user.reload

      monthly_expenses = 200.0
      expected_remaining_budget = user.maximum_budget - monthly_expenses

      expect(user.remaining_budget).to eq(expected_remaining_budget)
      expect(user.remaining_budget_reset_date).to eq(Date.today.next_month.beginning_of_month)
    end

    it 'sets remaining_budget to maximum_budget if there are no expenses in the current month' do
      user.update(remaining_budget_reset_date: Date.yesterday)
      user.reset_remaining_budget_if_needed
      user.reload

      expect(user.remaining_budget).to eq(user.maximum_budget)
      expect(user.remaining_budget_reset_date).to eq(Date.today.next_month.beginning_of_month)
    end

    it 'does not reset remaining budget if the reset date has not passed' do
      create(:expense, user: user, amount: 200.0)
      user.update(remaining_budget_reset_date: Date.today + 2.days)
      user.calculate_remaining_budget

      budget_before_reset = user.remaining_budget

      user.reset_remaining_budget_if_needed
      user.reload

      expect(user.remaining_budget).to eq(budget_before_reset)
    end
  end

  describe '#reset_all_remaining_budgets' do
    it 'calls reset_remaining_budget_if_needed for each user with a past remaining_budget_reset_date' do
      users = create_list(:user, 3, remaining_budget_reset_date: Date.yesterday)

      allow(User).to receive(:find_each).and_yield(users[0]).and_yield(users[1]).and_yield(users[2])
      users.each { |user| allow(user).to receive(:reset_remaining_budget_if_needed) }

      User.reset_all_remaining_budgets

      users.each do |user|
        expect(user).to have_received(:reset_remaining_budget_if_needed)
      end
    end
  end
end

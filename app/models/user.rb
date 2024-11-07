class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  before_create :set_remaining_budget_reset_date

  has_many :expenses, dependent: :destroy

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: true

  def update_maximum_budget(new_maximum_budget)
    update!(maximum_budget: new_maximum_budget)
    calculate_remaining_budget
  end

  def calculate_remaining_budget
    monthly_expenses = expenses.current_month.sum(:amount)
    new_remaining_budget = maximum_budget - monthly_expenses
    update!(remaining_budget: new_remaining_budget)
  end

  def self.reset_all_remaining_budgets
    User.find_each(&:reset_remaining_budget_if_needed)
  end

  def reset_remaining_budget_if_needed
    return unless Date.today >= remaining_budget_reset_date

    Rails.logger.info "Resetting budget for #{email}"
    update(remaining_budget_reset_date: remaining_budget_reset_date.next_month.beginning_of_month)
    calculate_remaining_budget
  end

  private

  def set_remaining_budget_reset_date
    self.remaining_budget_reset_date = Date.today.next_month.beginning_of_month
  end
end

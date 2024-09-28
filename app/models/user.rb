class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  before_create :set_initial_budget

  has_many :expenses, dependent: :destroy
  has_many :categories, through: :expenses

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true

  def calculate_budget
    total_expenses = expenses.sum(:amount)
    new_budget = 1000 - total_expenses
    update(budget: new_budget)
  end

  def self.reset_all_budgets
    User.find_each do |user|
      reset_budget_if_needed(user)
    end
  end

  def self.reset_budget_if_needed(user)
    return unless Date.today >= user.budget_reset_date

    Rails.logger.info "Resetting budget for #{user.email}"
    user.update(budget: 1000.00, budget_reset_date: user.budget_reset_date.next_month.beginning_of_month)
  end

  private

  def set_initial_budget
    self.budget = 1000.00
    self.budget_reset_date = Date.today.next_month.beginning_of_month
  end
end

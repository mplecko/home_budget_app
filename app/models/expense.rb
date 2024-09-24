class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true

  after_create :deduct_from_budget

  private

  def deduct_from_budget
    user.update(budget: user.budget - amount)
  end
end

class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :date, presence: true

  after_save :update_user_budget
  after_destroy :update_user_budget

  private

  def update_user_budget
    user.calculate_budget
  end
end

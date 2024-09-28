class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :description, :date, :category_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }

  after_save :update_user_budget
  after_destroy :update_user_budget

  private

  def update_user_budget
    user.calculate_budget
  end
end

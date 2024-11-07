class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :category

  validates :description, :date, :category_id, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :date_cannot_be_in_the_future

  after_save :update_user_remaining_budget
  after_destroy :update_user_remaining_budget

  scope :within_date_range, ->(start_date, end_date) { where(date: start_date..end_date) }
  scope :current_month, -> { where(date: Date.today.beginning_of_month..Date.today.end_of_month) }
  scope :within_price_range, ->(min_price, max_price) { where(amount: min_price..max_price) }

  private

  def update_user_remaining_budget
    user.calculate_remaining_budget
  end

  def date_cannot_be_in_the_future
    return unless date.nil? || date > Date.today

    errors.add(:date, "cannot be in the future")
  end
end

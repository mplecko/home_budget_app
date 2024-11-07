class ResetRemainingBudgetJob < ApplicationJob
  queue_as :default

  def perform
    User.reset_all_remaining_budgets
  end
end

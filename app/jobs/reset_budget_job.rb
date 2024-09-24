class ResetBudgetJob < ApplicationJob
  queue_as :default

  def perform
    User.reset_all_budgets
  end
end

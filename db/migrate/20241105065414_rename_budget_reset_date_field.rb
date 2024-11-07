class RenameBudgetResetDateField < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :budget_reset_date, :remaining_budget_reset_date
  end
end

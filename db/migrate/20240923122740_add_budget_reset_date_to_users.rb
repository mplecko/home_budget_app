class AddBudgetResetDateToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :budget_reset_date, :date
  end
end

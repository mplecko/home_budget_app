class UpdateUserBudgetFields < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :budget, :remaining_budget

    add_column :users, :maximum_budget, :decimal, precision: 10, scale: 2, default: 1000.0
  end
end

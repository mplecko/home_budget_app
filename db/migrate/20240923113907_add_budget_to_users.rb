class AddBudgetToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :budget, :decimal, precision: 10, scale: 2, default: 1000.00
  end
end

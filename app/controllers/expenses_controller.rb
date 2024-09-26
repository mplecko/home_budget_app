class ExpensesController < ApplicationController
  before_action :set_expense, only: [:show, :destroy]

  def index
    @expenses = current_user.expenses.all
    render json: @expenses
  end

  def show
    render json: @expense.as_json(include: { category: { only: [:id, :name] } }, except: [:created_at, :updated_at])
  end

  def create
    @expense = current_user.expenses.build(expense_params)
    @expense.save!

    render json: {
      expense: @expense.as_json(include: { category: { only: [:id, :name] } }, except: [:created_at, :updated_at]),
      remaining_budget: current_user.budget
    }, status: :created
  end

  def destroy
    @expense.destroy
    head :no_content
  end

  private

  def set_expense
    @expense = current_user.expenses.find(params[:id])
  end

  def expense_params
    params.require(:expense).permit(:description, :amount, :date, :category_id)
  end
end

class ExpensesController < ApplicationController
  before_action :set_expense, only: [:show, :destroy]

  def index
    @expenses = current_user.expenses.all
    render json: @expenses
  end

  def show
    render json: @expense
  end

  def create
    @expense = current_user.expenses.build(expense_params)
    @expense.save!

    render json: {
      expense: ExpenseSerializer.new(@expense).serializable_hash,
      remaining_budget: current_user.budget
    }, status: :created
  end

  def update
    @expense = current_user.expenses.find(params[:id])
    @expense.update!(expense_params)

    render json: {
      expense: ExpenseSerializer.new(@expense).serializable_hash,
      remaining_budget: current_user.budget
    }
  end

  def destroy
    @expense.destroy
    head :no_content
  end

  def date_range
    start_date = Date.parse(params.require(:start_date))
    end_date = Date.parse(params.require(:end_date))

    raise ArgumentError unless start_date <= end_date

    @expenses = current_user.expenses.where(date: start_date..end_date)
    total_expenses_in_given_range = @expenses.sum(:amount)

    render json: {
      total_expenses_in_given_range: total_expenses_in_given_range
    }
  end

  private

  def set_expense
    @expense = current_user.expenses.find(params[:id])
  end

  def expense_params
    params.require(:expense).permit(:description, :amount, :date, :category_id)
  end
end

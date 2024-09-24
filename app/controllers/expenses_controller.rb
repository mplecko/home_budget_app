class ExpensesController < ApplicationController
  before_action :authenticate_user!
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

    return render json: { errors: @expense.errors.full_messages }, status: :unprocessable_entity unless @expense.save

    render json: {
      expense: @expense.as_json(include: { category: { only: [:id, :name] } }, except: [:created_at, :updated_at]),
      remaining_budget: current_user.budget
    }, status: :created
  end

  def destroy
    @expense.destroy
    head :no_content
  end

  def statistics
    user_id = params[:user_id] || current_user.id
    current_time = Time.now

    expenses_this_month = Expense.where(user_id: user_id, date: current_time.beginning_of_month..current_time)
    expenses_last_week = Expense.where(user_id: user_id, date: current_time.last_week.all_week)
    expenses_last_month = Expense.where(user_id: user_id, date: current_time.last_month.all_month)
    expenses_last_quarter = Expense.where(user_id: user_id, date: (current_time - 3.months)..current_time)
    expenses_last_year = Expense.where(user_id: user_id, date: current_time.last_year.all_year)

    total_spent_this_month = expenses_this_month.sum(:amount)
    total_spent_last_week = expenses_last_week.sum(:amount)
    total_spent_last_month = expenses_last_month.sum(:amount)
    total_spent_last_quarter = expenses_last_quarter.sum(:amount)
    total_spent_last_year = expenses_last_year.sum(:amount)

    render json: {
      total_spent_this_month: total_spent_this_month,
      total_spent_last_week: total_spent_last_week,
      total_spent_last_month: total_spent_last_month,
      total_spent_last_quarter: total_spent_last_quarter,
      total_spent_last_year: total_spent_last_year
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

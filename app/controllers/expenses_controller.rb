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

  def filter
    expenses = current_user.expenses

    if params[:start_date].present? || params[:end_date].present?
      params.require([:start_date, :end_date])

      start_date = parse_date(params[:start_date], 'start_date')
      end_date = parse_date(params[:end_date], 'end_date')

      raise ArgumentError, 'Start date must be before or equal to end date' if start_date > end_date

      expenses = expenses.where(date: start_date..end_date)
    end

    if params[:min_price].present? || params[:max_price].present?
      params.require([:min_price, :max_price])

      min_price = parse_float(params[:min_price], 'min_price')
      max_price = parse_float(params[:max_price], 'max_price')

      raise ArgumentError, 'Minimum price must be less than or equal to maximum price' if min_price > max_price

      expenses = expenses.where(amount: min_price..max_price)
    end

    if params[:category_id].present?
      category = Category.find_by(id: params[:category_id])
      raise ActiveRecord::RecordNotFound, 'Category not found' unless category

      expenses = expenses.where(category_id: category.id)
    end

    total_expenses = expenses.sum(:amount)

    render json: {
      expenses: expenses,
      total_expenses: total_expenses
    }
  end

  private

  def set_expense
    @expense = current_user.expenses.find(params[:id])
  end

  def expense_params
    params.require(:expense).permit(:description, :amount, :date, :category_id)
  end

  def parse_date(date_str, param_name)
    Date.parse(date_str)
  rescue ArgumentError
    raise ArgumentError, "Invalid date format for #{param_name}"
  end

  def parse_float(value_str, param_name)
    Float(value_str)
  rescue ArgumentError
    raise ArgumentError, "Invalid number format for #{param_name}"
  end
end

class ExpensesController < ApplicationController
  before_action :set_expense, only: [:show, :update, :destroy]

  def index
    render json: current_user.expenses
  end

  def show
    render json: @expense
  end

  def create
    expense = current_user.expenses.build(expense_params)
    expense.save!

    render json: {
      expense: ExpenseSerializer.new(expense).serializable_hash,
      remaining_budget: current_user.remaining_budget
    }, status: :created
  end

  def update
    @expense.update!(expense_params)

    render json: {
      expense: ExpenseSerializer.new(@expense).serializable_hash,
      remaining_budget: current_user.remaining_budget
    }
  end

  def destroy
    @expense.destroy
    head :no_content
  end

  def filter
    expenses = current_user.expenses
    expenses = filter_by_date_range(expenses) if params[:start_date].present? || params[:end_date].present?
    expenses = filter_by_price_range(expenses) if params[:min_price].present? || params[:max_price].present?
    expenses = filter_by_category(expenses) if params[:category_id].present?

    serialized_expenses = expenses.map { |expense| ExpenseSerializer.new(expense).serializable_hash }

    render json: {
      expenses: serialized_expenses,
      total_expenses: expenses.sum(:amount)
    }
  end

  private

  def set_expense
    @expense = current_user.expenses.find(params[:id])
  end

  def expense_params
    params.require(:expense).permit(:description, :amount, :date, :category_id)
  end

  def filter_by_date_range(expenses)
    params.require([:start_date, :end_date])
    start_date = parse_date(params[:start_date], 'start_date')
    end_date = parse_date(params[:end_date], 'end_date')
    raise ArgumentError, 'Start date must be before or equal to end date' if start_date > end_date

    expenses.within_date_range(start_date, end_date)
  end

  def filter_by_price_range(expenses)
    params.require([:min_price, :max_price])
    min_price = parse_float(params[:min_price], 'min_price')
    max_price = parse_float(params[:max_price], 'max_price')
    raise ArgumentError, 'Minimum price must be less than or equal to maximum price' if min_price > max_price

    expenses.within_price_range(min_price, max_price)
  end

  def filter_by_category(expenses)
    category = Category.find_by(id: params[:category_id])
    raise ActiveRecord::RecordNotFound, 'Category not found' unless category

    expenses.where(category_id: category.id)
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

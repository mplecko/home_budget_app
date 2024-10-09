class CategoriesController < ApplicationController
  before_action :set_category, only: [:show, :update, :destroy]

  def index
    render json: Category.all
  end

  def show
    render json: @category
  end

  def create
    category = Category.new(category_params)
    category.save!
    render json: category, status: :created
  end

  def update
    @category.update!(category_params)
    render json: @category
  end

  def destroy
    if @category.expenses.any?
      @category.errors.add(:base, 'Cannot delete category with associated expenses')
      raise ActiveRecord::RecordInvalid, @category
    end

    @category.destroy
    head :no_content
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name)
  end
end

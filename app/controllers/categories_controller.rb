class CategoriesController < ApplicationController
  before_action :authenticate_user!

  before_action :set_category, only: [:show, :destroy]

  def index
    @categories = Category.all
    render json: @categories
  end

  def show
    render json: @category
  end

  def create
    @category = Category.new(category_params)

    return render json: @category, status: :created if @category.save

    render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
  end

  def destroy
    @category.destroy
    head :no_content
  end

  private

  def set_category
    @category = Category.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors: ['Category not found'] }, status: :not_found
  end

  def category_params
    params.require(:category).permit(:name)
  end
end

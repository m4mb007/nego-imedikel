class CategoriesController < ApplicationController
  before_action :set_category, only: [:show]

  def index
    @categories = Category.active.root_categories.ordered
  end

  def show
    @products = Product.active
                      .where(category: @category.all_subcategories + [@category])
                      .includes(:category, :user, :product_images)
                      .page(params[:page])
                      .per(20)
    
    @subcategories = @category.subcategories.active.ordered
    @brands = @products.distinct.pluck(:brand).compact.sort
  end

  private

  def set_category
    @category = Category.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Category not found."
    redirect_to categories_path
  end
end

class Admin::CategoriesController < ApplicationController
  before_action :require_admin
  before_action :set_category, only: [:show, :edit, :update, :destroy, :toggle_status]

  def index
    @categories = Category.order(:name)
    @categories = @categories.where(status: params[:status]) if params[:status].present?
    @categories = @categories.search(params[:search]) if params[:search].present?
  end

  def show
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(category_params)
    if @category.save
      redirect_to admin_category_path(@category), notice: 'Category created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(category_params)
      redirect_to admin_category_path(@category), notice: 'Category updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.products.exists?
      redirect_to admin_category_path(@category), alert: 'Cannot delete category with products.'
    else
      @category.destroy
      redirect_to admin_categories_path, notice: 'Category deleted successfully.'
    end
  end

  def toggle_status
    @category.update(status: @category.active? ? :inactive : :active)
    redirect_to admin_category_path(@category), notice: 'Category status updated successfully.'
  end

  private

  def set_category
    @category = Category.friendly.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :description, :status, :parent_id)
  end
end

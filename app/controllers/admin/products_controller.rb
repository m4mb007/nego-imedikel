class Admin::ProductsController < ApplicationController
  before_action :require_admin
  before_action :set_product, only: [:show, :edit, :update, :destroy, :toggle_status, :toggle_featured]

  def index
    @products = Product.includes(:store, :category).order(created_at: :desc)
    @products = @products.where(status: params[:status]) if params[:status].present?
    @products = @products.where(store_id: params[:store_id]) if params[:store_id].present?
    @products = @products.where(category_id: params[:category_id]) if params[:category_id].present?
    @products = @products.search(params[:search]) if params[:search].present?
    @products = @products.page(params[:page]).per(20)
  end

  def show
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to admin_product_path(@product), notice: 'Product updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to admin_products_path, notice: 'Product deleted successfully.'
  end

  def toggle_status
    @product.update(status: @product.active? ? :inactive : :active)
    redirect_to admin_product_path(@product), notice: 'Product status updated successfully.'
  end

  def toggle_featured
    @product.update(featured: !@product.featured?)
    redirect_to admin_product_path(@product), notice: 'Product featured status updated successfully.'
  end

  private

  def set_product
    @product = Product.friendly.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :status, :featured, :category_id)
  end
end

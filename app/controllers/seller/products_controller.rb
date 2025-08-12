class Seller::ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_seller_role
  before_action :set_product, only: [:show, :edit, :update, :destroy, :toggle_status, :toggle_featured]

  def index
    @products = current_user.products.includes(:category, :product_images)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(20)
  end

  def show
  end

  def new
    @product = current_user.products.build
    @categories = Category.active.root_categories.ordered
  end

  def create
    @product = current_user.products.build(product_params)
    
    if @product.save
      redirect_to seller_product_path(@product), notice: 'Product was successfully created.'
    else
      @categories = Category.active.root_categories.ordered
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.active.root_categories.ordered
  end

  def update
    if @product.update(product_params)
      redirect_to seller_product_path(@product), notice: 'Product was successfully updated.'
    else
      @categories = Category.active.root_categories.ordered
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy
    redirect_to seller_products_path, notice: 'Product was successfully deleted.'
  end

  def toggle_status
    new_status = @product.active? ? :inactive : :active
    @product.update(status: new_status)
    
    respond_to do |format|
      format.html { redirect_to seller_products_path, notice: "Product status updated to #{new_status}." }
      format.json { render json: { status: new_status } }
    end
  end

  def toggle_featured
    @product.update(featured: !@product.featured?)
    
    respond_to do |format|
      format.html { redirect_to seller_products_path, notice: "Product featured status updated." }
      format.json { render json: { featured: @product.featured? } }
    end
  end

  private

  def set_product
    @product = current_user.products.friendly.find(params[:id])
  end

  def product_params
    params.require(:product).permit(
      :name, :description, :price, :sku, :brand, :weight, :dimensions,
      :category_id, :status, :featured, :stock_quantity, :average_rating
    )
  end

  def ensure_seller_role
    unless current_user.seller?
      flash[:alert] = "Access denied. You need seller privileges to access this area."
      redirect_to root_path
    end
  end
end

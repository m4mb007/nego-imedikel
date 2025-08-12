class ProductsController < ApplicationController
  before_action :set_product, only: [:show]

  def index
    @q = Product.active.ransack(params[:q])
    @products = @q.result(distinct: true)
                  .includes(:category, :user, :product_images)
                  .page(params[:page])
                  .per(20)
    
    @categories = Category.active.root_categories.ordered
    @brands = Product.active.distinct.pluck(:brand).compact.sort
  end

  def show
    @related_products = Product.active
                              .where(category: @product.category)
                              .where.not(id: @product.id)
                              .limit(4)
    
    @reviews = @product.reviews.approved.includes(:user).limit(5)
    @average_rating = @product.average_rating
    @reviews_count = @product.reviews_count
  end

  def search
    @q = Product.active.ransack(params[:q])
    @products = @q.result(distinct: true)
                  .includes(:category, :user, :product_images)
                  .page(params[:page])
                  .per(20)
    
    @search_term = params[:q][:name_cont] if params[:q]
    @total_results = @products.total_count
    
    respond_to do |format|
      format.html { render :index }
      format.json { render json: @products }
    end
  end

  def category
    @category = Category.friendly.find(params[:id])
    @products = Product.active
                      .where(category: @category.all_subcategories + [@category])
                      .includes(:category, :user, :product_images)
                      .page(params[:page])
                      .per(20)
    
    @subcategories = @category.subcategories.active.ordered
    @brands = @products.distinct.pluck(:brand).compact.sort
    
    render :index
  end

  def brand
    @brand = params[:brand]
    @products = Product.active
                      .by_brand(@brand)
                      .includes(:category, :user, :product_images)
                      .page(params[:page])
                      .per(20)
    
    render :index
  end

  def featured
    @products = Product.active.featured
                      .includes(:category, :user, :product_images)
                      .page(params[:page])
                      .per(20)
    
    render :index
  end

  def new_arrivals
    @products = Product.active
                      .where('created_at >= ?', 30.days.ago)
                      .includes(:category, :user, :product_images)
                      .order(created_at: :desc)
                      .page(params[:page])
                      .per(20)
    
    render :index
  end

  def on_sale
    # This would show products with discounts/promotions
    @products = Product.active
                      .includes(:category, :user, :product_images)
                      .page(params[:page])
                      .per(20)
    
    render :index
  end

  private

  def set_product
    @product = Product.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Product not found."
    redirect_to products_path
  end
end

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
    
    @categories = Category.active.root_categories.ordered
    @brands = Product.active.distinct.pluck(:brand).compact.sort
    
    render :index
  end

  def new_arrivals
    @products = Product.active
                      .where('created_at >= ?', 30.days.ago)
                      .includes(:category, :user, :product_images)
                      .order(created_at: :desc)
                      .page(params[:page])
                      .per(20)
    
    @categories = Category.active.root_categories.ordered
    @brands = Product.active.distinct.pluck(:brand).compact.sort
    
    render :index
  end

  def on_sale
    # This would show products with discounts/promotions
    @products = Product.active
                      .includes(:category, :user, :product_images)
                      .page(params[:page])
                      .per(20)
    
    @categories = Category.active.root_categories.ordered
    @brands = Product.active.distinct.pluck(:brand).compact.sort
    
    render :index
  end

  def add_to_cart
    @product = Product.friendly.find(params[:id])
    
    unless user_signed_in?
      flash[:alert] = "Please sign in to add items to your cart."
      redirect_to new_user_session_path
      return
    end
    
    if @product.in_stock?
      # Check if item already exists in cart
      existing_cart_item = current_user.cart_items.find_by(product: @product)
      
      if existing_cart_item
        existing_cart_item.update(quantity: existing_cart_item.quantity + 1)
        flash[:notice] = "#{@product.name} quantity updated in cart!"
      else
        current_user.cart_items.create!(
          product: @product,
          quantity: 1
        )
        flash[:notice] = "#{@product.name} added to cart successfully!"
      end
    else
      flash[:alert] = "Sorry, this product is out of stock."
    end
    
    redirect_back(fallback_location: product_path(@product))
  end

  def add_to_wishlist
    @product = Product.friendly.find(params[:id])
    
    unless user_signed_in?
      flash[:alert] = "Please sign in to add items to your wishlist."
      redirect_to new_user_session_path
      return
    end
    
    # Check if item already exists in wishlist
    existing_wishlist_item = current_user.wishlist_items.find_by(product: @product)
    
    if existing_wishlist_item
      flash[:notice] = "#{@product.name} is already in your wishlist!"
    else
      current_user.wishlist_items.create!(product: @product)
      flash[:notice] = "#{@product.name} added to wishlist successfully!"
    end
    
    redirect_back(fallback_location: product_path(@product))
  end

  def remove_from_wishlist
    @product = Product.friendly.find(params[:id])
    
    unless user_signed_in?
      flash[:alert] = "Please sign in to manage your wishlist."
      redirect_to new_user_session_path
      return
    end
    
    wishlist_item = current_user.wishlist_items.find_by(product: @product)
    
    if wishlist_item
      wishlist_item.destroy
      flash[:notice] = "#{@product.name} removed from wishlist."
    else
      flash[:alert] = "Item not found in wishlist."
    end
    
    redirect_back(fallback_location: product_path(@product))
  end

  private

  def set_product
    @product = Product.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Product not found."
    redirect_to products_path
  end
end

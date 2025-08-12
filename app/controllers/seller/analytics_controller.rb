class Seller::AnalyticsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_seller_role

  def index
    @store = current_user.store
    
    # Sales analytics
    @total_sales = @store.orders.where(status: :delivered).sum(:total_amount)
    @monthly_sales = @store.orders.where(status: :delivered, created_at: 1.month.ago..Time.current).sum(:total_amount)
    @weekly_sales = @store.orders.where(status: :delivered, created_at: 1.week.ago..Time.current).sum(:total_amount)
    
    # Order analytics
    @total_orders = @store.orders.count
    @pending_orders = @store.orders.where(status: :pending).count
    @completed_orders = @store.orders.where(status: :delivered).count
    
    # Product analytics
    @total_products = current_user.products.count
    @active_products = current_user.products.where(status: :active).count
    @low_stock_products = current_user.products.where('stock_quantity <= 10').count
    
    # Recent activity
    @recent_orders = @store.orders.includes(:user).order(created_at: :desc).limit(10)
    @top_products = current_user.products.joins(:order_items)
                              .group('products.id')
                              .order('COUNT(order_items.id) DESC')
                              .limit(5)
  end

  private

  def ensure_seller_role
    unless current_user.seller?
      flash[:alert] = "You don't have permission to access this area."
      redirect_to root_path
    end
  end
end

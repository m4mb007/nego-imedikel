class Admin::ReportsController < ApplicationController
  before_action :require_admin

  def index
    @total_revenue = Order.where(status: :completed).sum(:total_amount)
    @total_orders = Order.count
    @total_users = User.count
    @total_stores = Store.count
    
    # Recent revenue
    @recent_revenue = Order.where(status: :completed)
                          .where('created_at >= ?', 30.days.ago)
                          .sum(:total_amount)
    
    # Top selling products
    @top_products = Product.joins(:order_items)
                          .group('products.id')
                          .order('SUM(order_items.quantity) DESC')
                          .limit(10)
    
    # Recent activity
    @recent_orders = Order.includes(:user, :store).order(created_at: :desc).limit(10)
    @recent_users = User.order(created_at: :desc).limit(10)
    @pending_stores = Store.where(status: :pending).limit(5)
  end
end

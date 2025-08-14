class Admin::DashboardController < ApplicationController
  before_action :require_admin
  
  def index
    @total_users = User.count
    @total_stores = Store.count
    @total_products = Product.count
    @total_orders = Order.count
    @recent_orders = Order.includes(:user, :store).order(created_at: :desc).limit(10)
    @pending_stores = Store.where(status: :pending).limit(5)
    @recent_users = User.order(created_at: :desc).limit(5)
  end
end

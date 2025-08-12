class Seller::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_seller_role

  def index
    @user = current_user
    @store = @user.store
    
    # Basic dashboard statistics
    @total_products = @store&.products&.count || 0
    @active_products = @store&.products&.where(status: 'active')&.count || 0
    @total_orders = @store&.orders&.count || 0
    @pending_orders = @store&.orders&.where(status: 'pending')&.count || 0
    
    # Recent orders
    @recent_orders = @store&.orders&.includes(:user, :order_items)&.order(created_at: :desc)&.limit(5) || []
    
    # Recent products
    @recent_products = @store&.products&.includes(:category)&.order(created_at: :desc)&.limit(5) || []
  end

  private

  def ensure_seller_role
    unless current_user.seller?
      flash[:alert] = "Access denied. You need seller privileges to access this area."
      redirect_to root_path
    end
  end
end

class Seller::OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_seller_role
  before_action :set_order, only: [:show, :confirm, :process_order, :ship, :deliver, :cancel]

  def index
    if current_user.store
      @orders = current_user.store.orders.includes(:user, :order_items => :product)
                            .order(created_at: :desc)
                            .page(params[:page])
                            .per(20)
    else
      @orders = []
    end
  end

  def show
    @order_items = @order.order_items.includes(:product)
  end

  def confirm
    if @order.update(status: :confirmed)
      flash[:notice] = "Order ##{@order.order_number} has been confirmed."
    else
      flash[:alert] = "Failed to confirm order."
    end
    redirect_to seller_order_path(@order)
  end

  def process_order
    if @order.update(status: :processing)
      flash[:notice] = "Order ##{@order.order_number} is now being processed."
    else
      flash[:alert] = "Failed to update order status."
    end
    redirect_to seller_order_path(@order)
  end

  def ship
    if @order.update(status: :shipped, shipped_at: Time.current)
      flash[:notice] = "Order ##{@order.order_number} has been marked as shipped."
    else
      flash[:alert] = "Failed to update order status."
    end
    redirect_to seller_order_path(@order)
  end

  def deliver
    if @order.update(status: :delivered, delivered_at: Time.current)
      flash[:notice] = "Order ##{@order.order_number} has been marked as delivered."
    else
      flash[:alert] = "Failed to update order status."
    end
    redirect_to seller_order_path(@order)
  end

  def cancel
    if @order.update(status: :cancelled, cancelled_at: Time.current)
      flash[:notice] = "Order ##{@order.order_number} has been cancelled."
    else
      flash[:alert] = "Failed to cancel order."
    end
    redirect_to seller_order_path(@order)
  end

  private

  def set_order
    @order = current_user.store.orders.find(params[:id])
  end

  def ensure_seller_role
    unless current_user.seller?
      flash[:alert] = "You don't have permission to access this area."
      redirect_to root_path
    end
  end
end

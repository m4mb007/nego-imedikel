class Admin::OrdersController < ApplicationController
  before_action :require_admin
  before_action :set_order, only: [:show, :update_status, :refund]

  def index
    @orders = Order.includes(:user, :store).order(created_at: :desc)
    @orders = @orders.where(status: params[:status]) if params[:status].present?
    @orders = @orders.where(store_id: params[:store_id]) if params[:store_id].present?
    @orders = @orders.search(params[:search]) if params[:search].present?
    @orders = @orders.page(params[:page]).per(20)
  end

  def show
  end

  def update_status
    if @order.update(status: params[:status])
      redirect_to admin_order_path(@order), notice: 'Order status updated successfully.'
    else
      redirect_to admin_order_path(@order), alert: 'Failed to update order status.'
    end
  end

  def refund
    if @order.update(status: :refunded)
      # Here you would typically integrate with payment gateway for refund
      redirect_to admin_order_path(@order), notice: 'Order refunded successfully.'
    else
      redirect_to admin_order_path(@order), alert: 'Failed to refund order.'
    end
  end

  private

  def set_order
    @order = Order.find(params[:id])
  end
end

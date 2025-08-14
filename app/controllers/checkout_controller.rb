class CheckoutController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart_items
  before_action :ensure_cart_not_empty

  def show
    # Main checkout page - order summary and shipping/billing info
    @shipping_addresses = current_user.addresses
    @billing_addresses = current_user.addresses
  end

  def update
    # Handle checkout form submission
    if params[:step] == 'shipping'
      session[:shipping_address_id] = params[:shipping_address_id]
      redirect_to shipping_checkout_path
    elsif params[:step] == 'payment'
      session[:billing_address_id] = params[:billing_address_id]
      redirect_to payment_checkout_path
    else
      redirect_to checkout_path, alert: 'Invalid checkout step.'
    end
  end

  def shipping
    # Shipping address selection page
    @shipping_addresses = current_user.addresses
  end

  def payment
    # Payment method selection page
    @billing_addresses = current_user.addresses
  end

  def confirmation
    # Order confirmation page
    @order = Order.find_by(id: session[:order_id])
    unless @order
      redirect_to checkout_path, alert: 'No order found for confirmation.'
    end
  end

  private

  def set_cart_items
    @cart_items = current_user.cart_items.includes(:product, :product_variant)
    @cart_total = @cart_items.sum(&:total_price)
  end

  def ensure_cart_not_empty
    if @cart_items.empty?
      redirect_to cart_path, alert: 'Your cart is empty. Please add items before checkout.'
    end
  end
end

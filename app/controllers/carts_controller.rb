class CartsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_cart_items

  def show
    # Cart items are loaded in before_action
  end

  def update
    # This would handle cart updates like quantity changes
    redirect_to cart_path, notice: 'Cart updated successfully.'
  end

  def destroy
    current_user.cart_items.destroy_all
    redirect_to cart_path, notice: 'Cart cleared successfully.'
  end

  private

  def set_cart_items
    @cart_items = current_user.cart_items.includes(:product, :product_variant)
    @cart_total = @cart_items.sum(&:total_price)
  end
end

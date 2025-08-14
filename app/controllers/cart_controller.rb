class CartController < ApplicationController
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

  def remove_item
    product_id = params[:product_id]
    product_variant_id = params[:product_variant_id]
    
    cart_item = current_user.cart_items.find_by(
      product_id: product_id,
      product_variant_id: product_variant_id
    )
    
    if cart_item
      cart_item.destroy
      redirect_to cart_path, notice: 'Item removed from cart successfully.'
    else
      redirect_to cart_path, alert: 'Item not found in cart.'
    end
  end

  private

  def set_cart_items
    @cart_items = current_user.cart_items.includes(:product, :product_variant)
    @cart_total = @cart_items.sum(&:total_price)
  end
end

class WishlistsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_wishlist_items

  def show
    # Wishlist items are loaded in before_action
  end

  private

  def set_wishlist_items
    @wishlist_items = current_user.wishlist_items.includes(:product)
  end
end

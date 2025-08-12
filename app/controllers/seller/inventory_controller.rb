class Seller::InventoryController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_seller_role

  def index
    @products = current_user.products.includes(:category)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(20)
    
    # Inventory statistics
    @total_products = current_user.products.count
    @low_stock_products = current_user.products.where('stock_quantity <= 10').count
    @out_of_stock_products = current_user.products.where(stock_quantity: 0).count
    @active_products = current_user.products.where(status: :active).count
  end

  def update
    @product = current_user.products.find(params[:id])
    
    if @product.update(inventory_params)
      flash[:notice] = "Inventory updated successfully for #{@product.name}"
    else
      flash[:alert] = "Failed to update inventory"
    end
    
    redirect_to seller_inventory_index_path
  end

  private

  def inventory_params
    params.require(:product).permit(:stock_quantity, :status)
  end

  def ensure_seller_role
    unless current_user.seller?
      flash[:alert] = "You don't have permission to access this area."
      redirect_to root_path
    end
  end
end

class StoresController < ApplicationController
  before_action :set_store, only: [:show]

  def index
    @stores = Store.active.verified.includes(:user).page(params[:page]).per(12)
  end

  def show
    @products = @store.user.products.active.includes(:category, :product_images).page(params[:page]).per(12)
    @reviews = Review.joins(product: :user).where(users: { id: @store.user_id }).approved.includes(:user).limit(5)
  end

  private

  def set_store
    @store = Store.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Store not found."
    redirect_to stores_path
  end
end

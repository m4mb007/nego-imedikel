class Seller::PromotionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_seller_role
  before_action :set_promotion, only: [:show, :edit, :update, :destroy]

  def index
    @promotions = current_user.store.promotions.order(created_at: :desc)
                              .page(params[:page])
                              .per(20)
  end

  def show
  end

  def new
    @promotion = current_user.store.promotions.build
  end

  def create
    @promotion = current_user.store.promotions.build(promotion_params)
    
    if @promotion.save
      flash[:notice] = "Promotion created successfully!"
      redirect_to seller_promotions_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @promotion.update(promotion_params)
      flash[:notice] = "Promotion updated successfully!"
      redirect_to seller_promotions_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @promotion.destroy
    flash[:notice] = "Promotion deleted successfully!"
    redirect_to seller_promotions_path
  end

  private

  def set_promotion
    @promotion = current_user.store.promotions.find(params[:id])
  end

  def promotion_params
    params.require(:promotion).permit(:name, :description, :discount_type, :discount_value, 
                                     :minimum_amount, :start_date, :end_date, :usage_limit, :status)
  end

  def ensure_seller_role
    unless current_user.seller?
      flash[:alert] = "You don't have permission to access this area."
      redirect_to root_path
    end
  end
end

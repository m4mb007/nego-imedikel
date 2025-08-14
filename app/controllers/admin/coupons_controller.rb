class Admin::CouponsController < ApplicationController
  before_action :require_admin
  before_action :set_coupon, only: [:show, :edit, :update, :destroy]

  def index
    @coupons = Coupon.order(created_at: :desc)
    @coupons = @coupons.where(status: params[:status]) if params[:status].present?
    @coupons = @coupons.search(params[:search]) if params[:search].present?
  end

  def show
  end

  def new
    @coupon = Coupon.new
  end

  def create
    @coupon = Coupon.new(coupon_params)
    if @coupon.save
      redirect_to admin_coupon_path(@coupon), notice: 'Coupon created successfully.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @coupon.update(coupon_params)
      redirect_to admin_coupon_path(@coupon), notice: 'Coupon updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @coupon.destroy
    redirect_to admin_coupons_path, notice: 'Coupon deleted successfully.'
  end

  private

  def set_coupon
    @coupon = Coupon.find(params[:id])
  end

  def coupon_params
    params.require(:coupon).permit(:code, :discount_type, :discount_value, :minimum_amount, :expires_at, :usage_limit, :status)
  end
end

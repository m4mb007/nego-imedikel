class Admin::StoresController < ApplicationController
  before_action :require_admin
  before_action :set_store, only: [:show, :edit, :update, :verify, :suspend, :activate]

  def index
    @stores = Store.includes(:user).order(created_at: :desc)
    @stores = @stores.where(status: params[:status]) if params[:status].present?
    @stores = @stores.search(params[:search]) if params[:search].present?
    @stores = @stores.page(params[:page]).per(20)
  end

  def show
  end

  def edit
  end

  def update
    if @store.update(store_params)
      redirect_to admin_store_path(@store), notice: 'Store updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def verify
    @store.update(status: :verified)
    redirect_to admin_store_path(@store), notice: 'Store verified successfully.'
  end

  def suspend
    @store.update(status: :suspended)
    redirect_to admin_store_path(@store), notice: 'Store suspended successfully.'
  end

  def activate
    @store.update(status: :active)
    redirect_to admin_store_path(@store), notice: 'Store activated successfully.'
  end

  private

  def set_store
    @store = Store.friendly.find(params[:id])
  end

  def store_params
    params.require(:store).permit(:name, :description, :status, :verified)
  end
end

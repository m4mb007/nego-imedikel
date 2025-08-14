class ProfileController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  def show
    @orders = @user.orders.includes(:order_items, :store).order(created_at: :desc).limit(10)
    @reviews = @user.reviews.includes(:product).order(created_at: :desc).limit(5)
    @addresses = @user.addresses.order(is_default: :desc, created_at: :desc)
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to profile_path, notice: 'Profile was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def orders
    @orders = @user.orders.includes(:order_items, :store)
                   .order(created_at: :desc)
                   .page(params[:page])
                   .per(20)
  end

  def wishlist
    @wishlist_items = @user.wishlist_items.includes(:product, :product_images)
                           .order(created_at: :desc)
                           .page(params[:page])
                           .per(20)
  end

  def reviews
    @reviews = @user.reviews.includes(:product)
                    .order(created_at: :desc)
                    .page(params[:page])
                    .per(20)
  end

  def addresses
    @addresses = @user.addresses.order(is_default: :desc, created_at: :desc)
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    params.require(:user).permit(
      :first_name, :last_name, :email, :phone, :date_of_birth,
      :gender, :profile_picture, :bio, :website, :social_links,
      :preferences, :notification_settings
    )
  end
end

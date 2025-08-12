class ReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:new, :create]
  before_action :set_review, only: [:edit, :update, :destroy]
  before_action :ensure_review_owner, only: [:edit, :update, :destroy]

  def new
    @review = @product.reviews.build
  end

  def create
    @review = @product.reviews.build(review_params)
    @review.user = current_user

    if @review.save
      flash[:notice] = "Review submitted successfully!"
      redirect_to product_path(@product)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @review.update(review_params)
      flash[:notice] = "Review updated successfully!"
      redirect_to product_path(@review.product)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    product = @review.product
    @review.destroy
    flash[:notice] = "Review deleted successfully!"
    redirect_to product_path(product)
  end

  private

  def set_product
    @product = Product.friendly.find(params[:product_id])
  end

  def set_review
    @review = Review.find(params[:id])
  end

  def ensure_review_owner
    unless @review.user == current_user
      flash[:alert] = "You can only edit your own reviews."
      redirect_to product_path(@review.product)
    end
  end

  def review_params
    params.require(:review).permit(:rating, :comment, :status)
  end
end

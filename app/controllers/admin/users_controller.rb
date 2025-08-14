class Admin::UsersController < ApplicationController
  before_action :require_admin
  before_action :set_user, only: [:show, :edit, :update, :verify, :suspend, :activate, :change_role]

  def index
    @users = User.includes(:store).order(created_at: :desc)
    @users = @users.where(role: params[:role]) if params[:role].present?
    @users = @users.search(params[:search]) if params[:search].present?
    @users = @users.page(params[:page]).per(20)
  end

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: 'User updated successfully.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def verify
    @user.update(verified: true)
    redirect_to admin_user_path(@user), notice: 'User verified successfully.'
  end

  def suspend
    @user.update(status: :suspended)
    redirect_to admin_user_path(@user), notice: 'User suspended successfully.'
  end

  def activate
    @user.update(status: :active)
    redirect_to admin_user_path(@user), notice: 'User activated successfully.'
  end

  def change_role
    if @user.update(role: params[:role])
      redirect_to admin_user_path(@user), notice: 'User role changed successfully.'
    else
      redirect_to admin_user_path(@user), alert: 'Failed to change user role.'
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, :phone, :role, :verified, :status)
  end
end

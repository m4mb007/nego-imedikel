class Admin::RewardsController < ApplicationController
  before_action :require_admin

  def index
    @total_wallets = RewardWallet.count
    @total_points = RewardWallet.sum(:points)
    @total_transactions = RewardTransaction.count
    @total_credits = RewardTransaction.credits.sum(:amount)
    @total_debits = RewardTransaction.debits.sum(:amount)
    
    @recent_transactions = RewardTransaction.includes(:reward_wallet => :user)
                                           .order(created_at: :desc)
                                           .limit(10)
    
    @top_users = RewardWallet.includes(:user)
                             .order(points: :desc)
                             .limit(10)
    
    @config = RewardsService.get_rewards_config
  end

  def edit
    @config = RewardsService.get_rewards_config
  end

  def update
    begin
      # Validate the parameters
      points_per_ringgit = params[:config][:points_per_ringgit].to_f
      redemption_percentage = params[:config][:redemption_percentage].to_f
      points_to_ringgit_ratio = params[:config][:points_to_ringgit_ratio].to_f
      min_redemption_amount = params[:config][:min_redemption_amount].to_i

      # Validate ranges
      if points_per_ringgit < 0 || points_per_ringgit > 10
        flash[:alert] = "Points per RM1 must be between 0 and 10"
        redirect_to edit_admin_rewards_path and return
      end

      if redemption_percentage < 0 || redemption_percentage > 100
        flash[:alert] = "Redemption percentage must be between 0 and 100"
        redirect_to edit_admin_rewards_path and return
      end

      if points_to_ringgit_ratio < 1 || points_to_ringgit_ratio > 1000
        flash[:alert] = "Points to RM ratio must be between 1 and 1000"
        redirect_to edit_admin_rewards_path and return
      end

      if min_redemption_amount < 0
        flash[:alert] = "Minimum redemption amount cannot be negative"
        redirect_to edit_admin_rewards_path and return
      end

      # Update the configuration in database
      RewardsService.update_config(
        points_per_ringgit: points_per_ringgit,
        redemption_percentage: redemption_percentage,
        points_to_ringgit_ratio: points_to_ringgit_ratio,
        min_redemption_amount: min_redemption_amount
      )

      flash[:notice] = "Rewards configuration updated successfully"
      redirect_to admin_rewards_path
    rescue => e
      flash[:alert] = "Error updating configuration: #{e.message}"
      redirect_to edit_admin_rewards_path
    end
  end

  def award_points
    user = User.find(params[:user_id])
    amount = params[:amount].to_i
    description = params[:description] || "Points awarded by admin"

    if amount <= 0
      flash[:alert] = "Amount must be greater than 0"
    elsif user.add_points(amount, description)
      flash[:notice] = "Successfully awarded #{amount} points to #{user.full_name}"
    else
      flash[:alert] = "Failed to award points"
    end

    redirect_to admin_rewards_path
  end
end

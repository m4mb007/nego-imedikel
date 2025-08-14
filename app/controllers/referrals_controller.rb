class ReferralsController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = current_user
    @referral_stats = MlmService.get_user_referral_stats(@user)
    @referral_tree = @user.referral_tree
    @commissions = @user.earned_commissions.includes(:user, :order).recent.limit(10)
    @referrals = @user.referred_users.includes(:user).recent.limit(10)
  end

  def apply
    referral_code = params[:referral_code]&.strip&.upcase
    
    if referral_code.blank?
      flash[:alert] = "Please enter a referral code"
      redirect_to referral_path and return
    end

    if MlmService.create_referral(current_user, referral_code)
      flash[:notice] = "Successfully applied referral code! You're now connected to the referral network."
    else
      flash[:alert] = "Invalid referral code or you're already referred"
    end

    redirect_to referral_path
  end
end

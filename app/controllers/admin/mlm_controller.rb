class Admin::MlmController < ApplicationController
  before_action :require_admin

  def index
    @summary = MlmService.get_commission_summary
    @total_referrals = Referral.active.count
    @total_referral_codes = ReferralCode.active.count
    @top_earners = User.joins(:earned_commissions)
                      .group('users.id')
                      .order('SUM(mlm_commissions.commission_amount) DESC')
                      .limit(10)
    @recent_commissions = MlmCommission.includes(:user, :referrer, :order)
                                      .recent
                                      .limit(10)
  end

  def show
    @user = User.find(params[:id])
    @referral_stats = MlmService.get_user_referral_stats(@user)
    @referral_tree = @user.referral_tree
    @commissions = @user.earned_commissions.includes(:user, :order).recent.limit(20)
    @referrals = @user.referred_users.includes(:user).recent.limit(20)
  end

  def payout
    @user = User.find(params[:user_id])
    @pending_commissions = @user.earned_commissions.pending
    @total_pending = @pending_commissions.sum(:commission_amount)
    @minimum_payout = MlmService.minimum_payout
  end

  def process_payout
    @user = User.find(params[:user_id])
    amount = params[:amount].to_f

    if MlmService.process_payout(@user, amount)
      flash[:notice] = "Successfully processed payout of RM#{amount} for #{@user.full_name}"
    else
      flash[:alert] = "Failed to process payout. Minimum payout amount is RM#{MlmService.minimum_payout}"
    end

    redirect_to admin_mlm_path(@user)
  end
end

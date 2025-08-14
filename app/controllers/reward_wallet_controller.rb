class RewardWalletController < ApplicationController
  before_action :authenticate_user!
  before_action :set_reward_wallet

  def show
    @transactions = @reward_wallet.recent_transactions(20)
    @config = RewardsService.get_rewards_config
  end

  private

  def set_reward_wallet
    @reward_wallet = current_user.reward_wallet_or_create
  end
end

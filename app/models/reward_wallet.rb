class RewardWallet < ApplicationRecord
  belongs_to :user
  has_many :reward_transactions, dependent: :destroy

  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :user_id, uniqueness: true

  # Scopes
  scope :with_points, -> { where('points > 0') }
  scope :recent, -> { order(updated_at: :desc) }

  # Methods
  def add_points(amount, description = nil, order = nil)
    return false if amount <= 0
    
    transaction do
      update!(points: points + amount)
      reward_transactions.create!(
        transaction_type: 'credit',
        amount: amount,
        description: description || "Points earned",
        order: order
      )
    end
    true
  rescue => e
    Rails.logger.error "Failed to add points: #{e.message}"
    false
  end

  def deduct_points(amount, description = nil, order = nil)
    return false if amount <= 0 || amount > points
    
    transaction do
      update!(points: points - amount)
      reward_transactions.create!(
        transaction_type: 'debit',
        amount: amount,
        description: description || "Points redeemed",
        order: order
      )
    end
    true
  rescue => e
    Rails.logger.error "Failed to deduct points: #{e.message}"
    false
  end

  def can_redeem?(amount)
    amount > 0 && amount <= points
  end

  def points_earned
    reward_transactions.where(transaction_type: 'credit').sum(:amount)
  end

  def points_redeemed
    reward_transactions.where(transaction_type: 'debit').sum(:amount)
  end

  def recent_transactions(limit = 10)
    reward_transactions.order(created_at: :desc).limit(limit)
  end

  def self.find_or_create_for_user(user)
    find_or_create_by(user: user) do |wallet|
      wallet.points = 0
    end
  end
end

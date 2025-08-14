class RewardTransaction < ApplicationRecord
  belongs_to :reward_wallet
  belongs_to :order, optional: true

  # Enums
  enum :transaction_type, { credit: 'credit', debit: 'debit' }

  # Validations
  validates :transaction_type, presence: true, inclusion: { in: transaction_types.keys }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true

  # Scopes
  scope :credits, -> { where(transaction_type: 'credit') }
  scope :debits, -> { where(transaction_type: 'debit') }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_order, ->(order) { where(order: order) }

  # Callbacks
  before_validation :set_default_description

  # Methods
  def credit?
    transaction_type == 'credit'
  end

  def debit?
    transaction_type == 'debit'
  end

  def formatted_amount
    "#{credit? ? '+' : '-'}#{amount} points"
  end

  def formatted_date
    created_at.strftime("%B %d, %Y at %I:%M %p")
  end

  private

  def set_default_description
    self.description ||= case transaction_type
                        when 'credit'
                          order ? "Points earned from order ##{order.id}" : "Points earned"
                        when 'debit'
                          order ? "Points redeemed for order ##{order.id}" : "Points redeemed"
                        end
  end
end

class ReferralCode < ApplicationRecord
  belongs_to :user
  has_many :referrals, dependent: :destroy

  validates :code, presence: true, uniqueness: true, length: { minimum: 6, maximum: 20 }
  validates :is_active, inclusion: { in: [true, false] }

  before_validation :generate_code, on: :create

  scope :active, -> { where(is_active: true) }
  scope :inactive, -> { where(is_active: false) }

  def self.generate_unique_code
    loop do
      code = SecureRandom.alphanumeric(8).upcase
      break code unless exists?(code: code)
    end
  end

  def deactivate!
    update!(is_active: false)
  end

  def activate!
    update!(is_active: true)
  end

  def usage_count
    referrals.count
  end

  def total_earnings
    MlmCommission.where(referrer: user).sum(:commission_amount)
  end

  private

  def generate_code
    self.code = self.class.generate_unique_code if code.blank?
  end
end

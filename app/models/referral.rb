class Referral < ApplicationRecord
  belongs_to :user
  belongs_to :referrer, class_name: 'User'
  belongs_to :referral_code

  validates :level, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 3 }
  validates :status, presence: true, inclusion: { in: %w[active inactive cancelled] }
  validates :user_id, uniqueness: { scope: :referrer_id, message: "can only be referred once by the same person" }

  scope :active, -> { where(status: 'active') }
  scope :inactive, -> { where(status: 'inactive') }
  scope :cancelled, -> { where(status: 'cancelled') }
  scope :by_level, ->(level) { where(level: level) }
  scope :recent, -> { order(created_at: :desc) }

  def self.create_referral_chain(user, referrer, referral_code)
    return false if user == referrer

    # Create direct referral (Level 1)
    direct_referral = create!(
      user: user,
      referrer: referrer,
      referral_code: referral_code,
      level: 1,
      status: 'active'
    )

    # Find referrer's referrer for Level 2
    referrer_referral = Referral.find_by(user: referrer, status: 'active')
    if referrer_referral
      create!(
        user: user,
        referrer: referrer_referral.referrer,
        referral_code: referral_code,
        level: 2,
        status: 'active'
      )

      # Find referrer's referrer's referrer for Level 3
      level2_referral = Referral.find_by(user: referrer_referral.referrer, status: 'active')
      if level2_referral
        create!(
          user: user,
          referrer: level2_referral.referrer,
          referral_code: referral_code,
          level: 3,
          status: 'active'
        )
      end
    end

    direct_referral
  end

  def cancel!
    update!(status: 'cancelled')
    # Cancel associated commissions
    MlmCommission.where(user: user, referrer: referrer, level: level).update_all(status: 'cancelled')
  end

  def reactivate!
    update!(status: 'active')
  end

  def active?
    status == 'active'
  end

  def cancelled?
    status == 'cancelled'
  end
end

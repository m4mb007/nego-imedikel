class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2, :facebook, :apple]

  # Enums
  enum :role, { customer: 0, seller: 1, admin: 2 }
  enum :status, { pending: 0, active: 1, suspended: 2, banned: 3 }

  # Associations
  has_one :store, dependent: :destroy
  has_one :reward_wallet, dependent: :destroy
  has_one :referral_code, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :cart_items, class_name: 'Cart', dependent: :destroy
  has_many :wishlist_items, class_name: 'Wishlist', dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :notifications, dependent: :destroy
  
  # MLM Associations
  has_many :referrals, class_name: 'Referral', foreign_key: 'user_id', dependent: :destroy
  has_many :referred_users, class_name: 'Referral', foreign_key: 'referrer_id', dependent: :destroy
  has_many :mlm_commissions, class_name: 'MlmCommission', foreign_key: 'user_id', dependent: :destroy
  has_many :earned_commissions, class_name: 'MlmCommission', foreign_key: 'referrer_id', dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :phone, presence: true, format: { with: /\A\+?[\d\s\-\(\)]+\z/ }
  validates :role, presence: true

  # Callbacks
  before_create :set_default_role
  # after_create :send_welcome_notification

  # Scopes
  scope :verified, -> { where.not(verified_at: nil) }
  scope :active_users, -> { where(status: :active) }
  scope :sellers, -> { where(role: :seller) }
  scope :search, ->(query) { 
    where("first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?", 
          "%#{query}%", "%#{query}%", "%#{query}%") if query.present?
  }

  # Methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def verified?
    verified_at.present?
  end

  def seller?
    role == 'seller'
  end

  def admin?
    role == 'admin'
  end

  def has_store?
    store.present?
  end

  def default_address
    addresses.find_by(is_default: true) || addresses.first
  end

  def cart_total
    cart_items.joins(:product).sum('carts.quantity * products.price')
  end

  def cart_items_count
    cart_items.sum(:quantity)
  end

  def reward_wallet_or_create
    reward_wallet || create_reward_wallet(points: 0)
  end

  def points_balance
    reward_wallet_or_create.points
  end

  def add_points(amount, description = nil, order = nil)
    reward_wallet_or_create.add_points(amount, description, order)
  end

  def deduct_points(amount, description = nil, order = nil)
    reward_wallet_or_create.deduct_points(amount, description, order)
  end

  def can_redeem_points?(amount)
    reward_wallet_or_create.can_redeem?(amount)
  end

  # MLM Methods
  def referral_code_or_create
    referral_code || create_referral_code
  end

  def referral_code_string
    referral_code_or_create.code
  end

  def total_referrals
    referred_users.active.count
  end

  def total_earnings
    earned_commissions.paid.sum(:commission_amount)
  end

  def pending_earnings
    earned_commissions.pending.sum(:commission_amount)
  end

  def total_commissions_by_level(level)
    earned_commissions.by_level(level).paid.sum(:commission_amount)
  end

  def referral_tree
    {
      level1: referred_users.by_level(1).active.includes(:user),
      level2: referred_users.by_level(2).active.includes(:user),
      level3: referred_users.by_level(3).active.includes(:user)
    }
  end

  def can_refer_user?(user)
    return false if user == self
    return false if referrals.exists?(referrer: user)
    return false if referred_users.exists?(user: user)
    true
  end

  def refer_user(user, referral_code)
    return false unless can_refer_user?(user)
    Referral.create_referral_chain(user, self, referral_code)
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.first_name = auth.info.first_name || auth.info.name.split.first
      user.last_name = auth.info.last_name || auth.info.name.split.last
      user.verified_at = Time.current if auth.info.email_verified
    end
  end

  private

  def set_default_role
    self.role ||= :customer
    self.status ||= :pending
  end

  def send_welcome_notification
    notifications.create(
      title: 'Welcome to NEGO!',
      message: "Thank you for joining NEGO, #{first_name}! Start exploring our marketplace.",
      notification_type: :welcome
    )
  end
end

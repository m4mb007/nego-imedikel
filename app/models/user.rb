class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2, :facebook, :apple]

  # Enums
  enum :role, { customer: 0, seller: 1, admin: 2 }
  enum :status, { pending: 0, active: 1, suspended: 2, banned: 3 }

  # Associations
  has_one :store, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :cart_items, class_name: 'Cart', dependent: :destroy
  has_many :wishlist_items, class_name: 'Wishlist', dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :notifications, dependent: :destroy

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

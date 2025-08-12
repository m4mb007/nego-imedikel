class Store < ApplicationRecord
  include FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  belongs_to :user
  has_many :products, through: :user
  has_many :orders, dependent: :destroy
  has_one_attached :logo
  has_one_attached :banner

  # Enums
  enum :status, { pending: 0, active: 1, suspended: 2, closed: 3 }

  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :phone, presence: true, format: { with: /\A\+?[\d\s\-\(\)]+\z/ }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :address, presence: true, length: { minimum: 10, maximum: 500 }
  validates :website, format: { with: URI::regexp(%w[http https]) }, allow_blank: true
  # validates :logo, content_type: ['image/png', 'image/jpeg', 'image/jpg'], size: { less_than: 5.megabytes }
  # validates :banner, content_type: ['image/png', 'image/jpeg', 'image/jpg'], size: { less_than: 10.megabytes }

  # Callbacks
  before_create :set_default_status
  before_save :normalize_slug
  after_create :send_store_created_notification

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :verified, -> { where.not(verified_at: nil) }
  scope :featured, -> { where(featured: true) }
  scope :recent, -> { order(created_at: :desc) }

  # Methods
  def verified?
    verified_at.present?
  end

  def active?
    status == 'active'
  end

  def can_sell?
    active? && verified?
  end

  def total_products
    user.products.count
  end

  def active_products
    user.products.active.count
  end

  def total_orders
    orders.count
  end

  def total_sales
    orders.completed.sum(:total_amount)
  end

  def average_rating
    reviews = Review.joins(product: :user).where(users: { id: user_id })
    reviews.average(:rating)&.round(1) || 0
  end

  def reviews_count
    reviews = Review.joins(product: :user).where(users: { id: user_id })
    reviews.count
  end

  def logo_url
    return nil unless logo.attached?
    logo
  end

  def banner_url
    return nil unless banner.attached?
    banner
  end

  def logo_thumbnail
    return nil unless logo.attached?
    logo.variant(resize_to_limit: [100, 100])
  end

  def banner_thumbnail
    return nil unless banner.attached?
    banner.variant(resize_to_limit: [300, 150])
  end

  def owner
    user
  end

  def contact_info
    {
      phone: phone,
      email: email,
      website: website,
      address: address
    }
  end

  def stats
    {
      total_products: total_products,
      active_products: active_products,
      total_orders: total_orders,
      total_sales: total_sales,
      average_rating: average_rating,
      reviews_count: reviews_count
    }
  end

  def verify!
    update(verified_at: Time.current, status: :active)
    send_verification_notification
  end

  def suspend!
    update(status: :suspended)
    send_suspension_notification
  end

  def activate!
    update(status: :active)
    send_activation_notification
  end

  private

  def set_default_status
    self.status ||= :pending
  end

  def normalize_slug
    self.slug = name.parameterize if slug.blank? || name_changed?
  end

  def send_store_created_notification
    user.notifications.create(
      title: 'Store Created Successfully',
      message: "Your store '#{name}' has been created and is pending verification.",
      notification_type: :store_created
    )
  end

  def send_verification_notification
    user.notifications.create(
      title: 'Store Verified',
      message: "Congratulations! Your store '#{name}' has been verified and is now active.",
      notification_type: :store_verified
    )
  end

  def send_suspension_notification
    user.notifications.create(
      title: 'Store Suspended',
      message: "Your store '#{name}' has been suspended. Please contact support for more information.",
      notification_type: :store_suspended
    )
  end

  def send_activation_notification
    user.notifications.create(
      title: 'Store Reactivated',
      message: "Your store '#{name}' has been reactivated and is now live again.",
      notification_type: :store_activated
    )
  end
end

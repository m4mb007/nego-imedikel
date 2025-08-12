class Order < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :store
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  has_many :notifications, as: :notifiable, dependent: :destroy

  # Enums
  enum :status, { pending: 0, confirmed: 1, processing: 2, shipped: 3, delivered: 4, cancelled: 5, refunded: 6 }
  enum :payment_status, { payment_pending: 0, paid: 1, failed: 2, payment_refunded: 3, partially_refunded: 4 }

  # Validations
  validates :total_amount, presence: true, numericality: { greater_than: 0 }
  validates :shipping_address, presence: true
  validates :billing_address, presence: true
  validates :tracking_number, uniqueness: true, allow_blank: true

  # Callbacks
  before_create :generate_order_number
  after_create :send_order_confirmation
  after_update :send_status_update_notification

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :this_month, -> { where(created_at: Time.current.beginning_of_month..Time.current.end_of_month) }
  scope :this_year, -> { where(created_at: Time.current.beginning_of_year..Time.current.end_of_year) }
  scope :completed, -> { where(status: :delivered) }
  scope :pending_payment, -> { where(payment_status: :pending) }
  scope :paid, -> { where(payment_status: :paid) }

  # Money configuration
  # monetize :total_amount_cents

  # Methods
  def order_number
    "NEGO#{id.to_s.rjust(8, '0')}"
  end

  def subtotal
    order_items.sum(&:total_price)
  end

  def shipping_cost
    # This would be calculated based on shipping method and location
    10.00
  end

  def tax_amount
    # This would be calculated based on location and tax rates
    subtotal * 0.06 # 6% tax rate
  end

  def discount_amount
    # This would be calculated based on applied coupons
    0.00
  end

  def total_items
    order_items.sum(:quantity)
  end

  def can_cancel?
    %w[pending confirmed processing].include?(status)
  end

  def can_refund?
    %w[delivered].include?(status) && payment_status == 'paid'
  end

  def can_track?
    %w[shipped delivered].include?(status)
  end

  def estimated_delivery_date
    return nil unless shipped?
    shipped_at + 3.days # Default 3-day delivery
  end

  def is_overdue?
    return false unless shipped?
    estimated_delivery_date < Time.current
  end

  def cancel!
    return false unless can_cancel?
    
    transaction do
      update(status: :cancelled)
      restore_inventory
      send_cancellation_notification
    end
  end

  def confirm!
    update(status: :confirmed)
    send_confirmation_notification
  end

  def process!
    update(status: :processing)
    send_processing_notification
  end

  def ship!(tracking_number = nil)
    update(status: :shipped, tracking_number: tracking_number, shipped_at: Time.current)
    send_shipping_notification
  end

  def deliver!
    update(status: :delivered, delivered_at: Time.current)
    send_delivery_notification
  end

  def refund!(amount = nil)
    return false unless can_refund?
    
    refund_amount = amount || total_amount
    update(status: :refunded, payment_status: :refunded)
    send_refund_notification(refund_amount)
  end

  def mark_as_paid!
    update(payment_status: :paid, paid_at: Time.current)
    send_payment_confirmation
  end

  def status_timeline
    timeline = []
    timeline << { status: 'Order Placed', time: created_at }
    timeline << { status: 'Order Confirmed', time: confirmed_at } if confirmed_at
    timeline << { status: 'Processing', time: processing_at } if processing_at
    timeline << { status: 'Shipped', time: shipped_at } if shipped_at
    timeline << { status: 'Delivered', time: delivered_at } if delivered_at
    timeline
  end

  def customer
    user
  end

  def seller
    store.user
  end

  private

  def generate_order_number
    # Order number is generated using the ID, so this is handled in the order_number method
  end

  def restore_inventory
    order_items.each do |item|
      if item.product_variant
        item.product_variant.increment!(:stock_quantity, item.quantity)
      else
        item.product.increment_stock(item.quantity)
      end
    end
  end

  def send_order_confirmation
    user.notifications.create(
      title: 'Order Confirmed',
      message: "Your order #{order_number} has been placed successfully.",
      notification_type: :order_placed,
      data: { order_id: id }
    )
  end

  def send_status_update_notification
    return unless status_previously_changed?
    
    user.notifications.create(
      title: "Order #{status.humanize}",
      message: "Your order #{order_number} has been #{status}.",
      notification_type: "order_#{status}",
      data: { order_id: id, status: status }
    )
  end

  def send_confirmation_notification
    user.notifications.create(
      title: 'Order Confirmed by Seller',
      message: "Your order #{order_number} has been confirmed by the seller.",
      notification_type: :order_confirmed,
      data: { order_id: id }
    )
  end

  def send_processing_notification
    user.notifications.create(
      title: 'Order Processing',
      message: "Your order #{order_number} is being processed.",
      notification_type: :order_processing,
      data: { order_id: id }
    )
  end

  def send_shipping_notification
    user.notifications.create(
      title: 'Order Shipped',
      message: "Your order #{order_number} has been shipped. Tracking: #{tracking_number}",
      notification_type: :order_shipped,
      data: { order_id: id, tracking_number: tracking_number }
    )
  end

  def send_delivery_notification
    user.notifications.create(
      title: 'Order Delivered',
      message: "Your order #{order_number} has been delivered. Please confirm receipt.",
      notification_type: :order_delivered,
      data: { order_id: id }
    )
  end

  def send_cancellation_notification
    user.notifications.create(
      title: 'Order Cancelled',
      message: "Your order #{order_number} has been cancelled.",
      notification_type: :order_cancelled,
      data: { order_id: id }
    )
  end

  def send_refund_notification(amount)
    user.notifications.create(
      title: 'Order Refunded',
      message: "Your order #{order_number} has been refunded for #{amount}.",
      notification_type: :order_refunded,
      data: { order_id: id, refund_amount: amount }
    )
  end

  def send_payment_confirmation
    user.notifications.create(
      title: 'Payment Confirmed',
      message: "Payment for order #{order_number} has been confirmed.",
      notification_type: :payment_confirmed,
      data: { order_id: id }
    )
  end
end

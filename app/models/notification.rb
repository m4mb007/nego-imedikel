class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true

  # Enums
  enum :notification_type, { 
    welcome: 0, 
    order_placed: 1, 
    order_confirmed: 2, 
    order_processing: 3, 
    order_shipped: 4, 
    order_delivered: 5, 
    order_cancelled: 6, 
    order_refunded: 7, 
    payment_confirmed: 8,
    store_created: 9,
    store_verified: 10,
    store_suspended: 11,
    store_activated: 12,
    general: 13
  }

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :message, presence: true, length: { maximum: 1000 }
  validates :notification_type, presence: true

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # Methods
  def mark_as_read!
    update(read_at: Time.current)
  end

  def read?
    read_at.present?
  end

  def unread?
    read_at.nil?
  end
end

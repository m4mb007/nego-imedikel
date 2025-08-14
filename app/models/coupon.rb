class Coupon < ApplicationRecord
  # Enums
  enum :discount_type, { percentage: 0, fixed_amount: 1 }
  enum :status, { inactive: 0, active: 1, expired: 2 }

  # Validations
  validates :code, presence: true, uniqueness: true, format: { with: /\A[A-Z0-9]+\z/, message: "must contain only uppercase letters and numbers" }
  validates :discount_value, presence: true, numericality: { greater_than: 0 }
  validates :minimum_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :maximum_discount, numericality: { greater_than: 0 }, allow_nil: true
  validates :usage_limit, numericality: { greater_than: 0 }, allow_nil: true
  validates :valid_from, presence: true
  validates :valid_until, presence: true

  # Callbacks
  before_validation :normalize_code
  after_create :set_default_status

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :valid, -> { where('valid_from <= ? AND valid_until >= ?', Time.current, Time.current) }
  scope :available, -> { active.valid }
  scope :search, ->(query) { 
    where("code ILIKE ? OR description ILIKE ?", 
          "%#{query}%", "%#{query}%") if query.present?
  }

  # Methods
  def valid_for_amount?(amount)
    return false unless active? && valid_period?
    return false if usage_limit_reached?
    return true if minimum_amount.nil?
    amount >= minimum_amount
  end

  def calculate_discount(amount)
    return 0 unless valid_for_amount?(amount)
    
    discount = if percentage?
      amount * (discount_value / 100.0)
    else
      discount_value
    end
    
    if maximum_discount && discount > maximum_discount
      maximum_discount
    else
      discount
    end
  end

  def valid_period?
    Time.current >= valid_from && Time.current <= valid_until
  end

  def usage_limit_reached?
    return false if usage_limit.nil?
    used_count >= usage_limit
  end

  def can_use?
    active? && valid_period? && !usage_limit_reached?
  end

  def increment_usage!
    increment!(:used_count)
  end

  def expire!
    update(status: :expired)
  end

  private

  def normalize_code
    self.code = code&.upcase&.strip
  end

  def set_default_status
    update(status: :active) if status.nil?
  end
end

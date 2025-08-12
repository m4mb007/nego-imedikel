class Cart < ApplicationRecord
  belongs_to :user
  belongs_to :product
  belongs_to :product_variant, optional: true

  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :product_id, presence: true
  validates :user_id, presence: true

  def total_price
    quantity * (product_variant&.price || product.price)
  end
end

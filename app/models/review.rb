class Review < ApplicationRecord
  belongs_to :user
  belongs_to :product

  # Enums
  enum :status, { pending: 0, approved: 1, rejected: 2 }

  # Validations
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :user_id, uniqueness: { scope: :product_id, message: "You have already reviewed this product" }

  # Scopes
  scope :approved, -> { where(status: :approved) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_rating, ->(rating) { where(rating: rating) }

  # Callbacks
  after_create :update_product_rating
  after_update :update_product_rating

  # Methods
  def can_edit?(user)
    user == self.user
  end

  def can_delete?(user)
    user == self.user || user.admin?
  end

  private

  def update_product_rating
    product.update_column(:average_rating, product.reviews.approved.average(:rating)&.round(1) || 0)
  end
end

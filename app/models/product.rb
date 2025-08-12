class Product < ApplicationRecord
  include FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  belongs_to :category
  belongs_to :user
  has_many :product_images, dependent: :destroy
  has_many :product_variants, dependent: :destroy
  has_many :cart_items, class_name: 'Cart', dependent: :destroy
  has_many :wishlist_items, class_name: 'Wishlist', dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :order_items, dependent: :destroy

  # Enums
  enum :status, { draft: 0, active: 1, inactive: 2, archived: 3 }

  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 200 }
  validates :description, presence: true, length: { minimum: 10, maximum: 2000 }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :sku, presence: true, uniqueness: true
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :weight, numericality: { greater_than: 0 }, allow_nil: true
  validates :brand, presence: true, length: { minimum: 2, maximum: 100 }

  # Callbacks
  before_create :generate_sku
  before_save :normalize_slug
  after_save :update_search_index

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :featured, -> { where(featured: true) }
  scope :in_stock, -> { where('stock_quantity > 0') }
  scope :out_of_stock, -> { where(stock_quantity: 0) }
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { joins(:reviews).group('products.id').order('AVG(reviews.rating) DESC') }
  scope :price_range, ->(min, max) { where(price: min..max) }
  scope :by_brand, ->(brand) { where(brand: brand) }

  # Money configuration
  # monetize :price_cents

  # Methods
  def available?
    active? && stock_quantity > 0
  end

  def out_of_stock?
    stock_quantity <= 0
  end

  def in_stock?
    stock_quantity > 0
  end

  def out_of_stock?
    stock_quantity <= 0
  end

  def low_stock?
    stock_quantity <= 10 && stock_quantity > 0
  end

  def main_image
    product_images.order(:position).first
  end

  def images
    product_images.order(:position)
  end

  def average_rating
    reviews.average(:rating)&.round(1) || 0
  end

  def reviews_count
    reviews.count
  end

  def has_variants?
    product_variants.exists?
  end

  def min_price
    return price unless has_variants?
    product_variants.minimum(:price) || price
  end

  def max_price
    return price unless has_variants?
    product_variants.maximum(:price) || price
  end

  def price_range
    return [price, price] unless has_variants?
    [min_price, max_price]
  end

  def total_stock
    base_stock = stock_quantity
    variant_stock = product_variants.sum(:stock_quantity)
    base_stock + variant_stock
  end

  def decrement_stock(quantity = 1)
    update(stock_quantity: stock_quantity - quantity) if stock_quantity >= quantity
  end

  def increment_stock(quantity = 1)
    update(stock_quantity: stock_quantity + quantity)
  end

  def seller
    user
  end

  def store
    user.store
  end

  def category_path
    category.breadcrumb.map(&:name).join(' > ')
  end

  def search_data
    {
      name: name,
      description: description,
      brand: brand,
      sku: sku,
      category_name: category.name,
      seller_name: user.full_name,
      store_name: user.store&.name
    }
  end

  private

  def generate_sku
    return if sku.present?
    
    loop do
      self.sku = "PROD#{SecureRandom.alphanumeric(8).upcase}"
      break unless Product.exists?(sku: sku)
    end
  end

  def normalize_slug
    self.slug = name.parameterize if slug.blank? || name_changed?
  end

  def update_search_index
    # This would integrate with Elasticsearch or similar search service
    # SearchIndexJob.perform_later(self) if Rails.application.config.search_enabled
  end
end

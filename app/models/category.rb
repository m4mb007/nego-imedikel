class Category < ApplicationRecord
  include FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  belongs_to :parent, class_name: 'Category', optional: true
  has_many :subcategories, class_name: 'Category', foreign_key: 'parent_id', dependent: :destroy
  has_many :products, dependent: :destroy

  # Enums
  enum :status, { inactive: 0, active: 1 }

  # Validations
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :slug, presence: true, uniqueness: true
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # Callbacks
  before_create :set_default_position
  before_save :normalize_slug

  # Scopes
  scope :active, -> { where(status: :active) }
  scope :root_categories, -> { where(parent_id: nil) }
  scope :ordered, -> { order(:position, :name) }
  scope :with_products, -> { joins(:products).distinct }
  scope :search, ->(query) { 
    where("name ILIKE ? OR description ILIKE ?", 
          "%#{query}%", "%#{query}%") if query.present?
  }

  # Methods
  def root?
    parent_id.nil?
  end

  def leaf?
    subcategories.empty?
  end

  def active?
    status == 'active'
  end

  def has_products?
    products.exists?
  end

  def all_subcategories
    subcategories.includes(:subcategories)
  end

  def all_products
    products.or(Category.where(id: subcategories.pluck(:id)).joins(:products).select('products.*'))
  end

  def breadcrumb
    breadcrumb_items = []
    current = self
    
    while current
      breadcrumb_items.unshift(current)
      current = current.parent
    end
    
    breadcrumb_items
  end

  def level
    return 0 if root?
    parent.level + 1
  end

  def max_level_reached?
    level >= 3 # Maximum 3 levels deep
  end

  def can_have_subcategories?
    !max_level_reached?
  end

  def products_count
    products.count
  end

  def total_products_count
    all_products.count
  end

  private

  def set_default_position
    self.position ||= Category.maximum(:position).to_i + 1
  end

  def normalize_slug
    self.slug = name.parameterize if slug.blank? || name_changed?
  end
end

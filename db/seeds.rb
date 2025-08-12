# Clear existing data
puts "Clearing existing data..."
Review.destroy_all
OrderItem.destroy_all
Cart.destroy_all
Wishlist.destroy_all
Address.destroy_all
Notification.destroy_all
ProductImage.destroy_all
ProductVariant.destroy_all
Product.destroy_all
Store.destroy_all
Category.destroy_all
User.destroy_all

# Create admin user
puts "Creating admin user..."
admin = User.create!(
  email: 'admin@nego.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Admin',
  last_name: 'User',
  phone: '+60123456789',
  role: :admin,
  status: :active,
  verified_at: Time.current
)

# Create test seller
puts "Creating test seller..."
seller = User.create!(
  email: 'seller@nego.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Test',
  last_name: 'Seller',
  phone: '+60123456788',
  role: :seller,
  status: :active,
  verified_at: Time.current
)

# Create test customer
puts "Creating test customer..."
customer = User.create!(
  email: 'customer@nego.com',
  password: 'password123',
  password_confirmation: 'password123',
  first_name: 'Test',
  last_name: 'Customer',
  phone: '+60123456787',
  role: :customer,
  status: :active,
  verified_at: Time.current
)

# Create main categories
puts "Creating main categories..."
electronics = Category.create!(
  name: 'Electronics',
  description: 'Electronic devices and gadgets',
  slug: 'electronics',
  position: 1,
  status: :active
)

fashion = Category.create!(
  name: 'Fashion',
  description: 'Clothing, shoes, and accessories',
  slug: 'fashion',
  position: 2,
  status: :active
)

home = Category.create!(
  name: 'Home & Living',
  description: 'Home decor and furniture',
  slug: 'home-living',
  position: 3,
  status: :active
)

health = Category.create!(
  name: 'Health & Beauty',
  description: 'Health products and beauty items',
  slug: 'health-beauty',
  position: 4,
  status: :active
)

food = Category.create!(
  name: 'Food & Beverages',
  description: 'Halal food and beverages',
  slug: 'food-beverages',
  position: 5,
  status: :active
)

books = Category.create!(
  name: 'Books & Media',
  description: 'Books, magazines, and media',
  slug: 'books-media',
  position: 6,
  status: :active
)

# Create subcategories
puts "Creating subcategories..."

# Electronics subcategories
smartphones = Category.create!(
  name: 'Smartphones',
  description: 'Mobile phones and accessories',
  slug: 'smartphones',
  parent: electronics,
  position: 1,
  status: :active
)

laptops = Category.create!(
  name: 'Laptops & Computers',
  description: 'Laptops, desktops, and computer accessories',
  slug: 'laptops-computers',
  parent: electronics,
  position: 2,
  status: :active
)

# Fashion subcategories
men_clothing = Category.create!(
  name: "Men's Clothing",
  description: 'Clothing for men',
  slug: 'mens-clothing',
  parent: fashion,
  position: 1,
  status: :active
)

women_clothing = Category.create!(
  name: "Women's Clothing",
  description: 'Clothing for women',
  slug: 'womens-clothing',
  parent: fashion,
  position: 2,
  status: :active
)

# Health subcategories
skincare = Category.create!(
  name: 'Skincare',
  description: 'Facial and body skincare products',
  slug: 'skincare',
  parent: health,
  position: 1,
  status: :active
)

supplements = Category.create!(
  name: 'Supplements',
  description: 'Health supplements and vitamins',
  slug: 'supplements',
  parent: health,
  position: 2,
  status: :active
)

# Create store for seller
puts "Creating store for seller..."
store = Store.create!(
  user: seller,
  name: 'TechMart Malaysia',
  description: 'Your trusted source for electronics and gadgets in Malaysia. We offer the latest smartphones, laptops, and accessories with competitive prices and excellent customer service.',
  phone: '+60123456788',
  email: 'info@techmart.com',
  website: 'https://techmart.com',
  address: '123 Jalan Tun Razak, Kuala Lumpur, Malaysia',
  status: :active,
  verified_at: Time.current
)

# Create sample products
puts "Creating sample products..."

# Electronics products
iphone = Product.create!(
  name: 'iPhone 15 Pro Max',
  description: 'The latest iPhone with advanced camera system, A17 Pro chip, and titanium design. Available in multiple colors and storage options.',
  price: 5999.00,
  sku: 'IPHONE15PM',
  category: smartphones,
  user: seller,
  status: :active,
  featured: true,
  stock_quantity: 50,
  weight: 0.221,
  dimensions: '159.9 x 77.6 x 8.25 mm',
  brand: 'Apple'
)

samsung_galaxy = Product.create!(
  name: 'Samsung Galaxy S24 Ultra',
  description: 'Premium Android smartphone with S Pen, advanced AI features, and exceptional camera capabilities. Perfect for productivity and creativity.',
  price: 5499.00,
  sku: 'SAMSUNG24U',
  category: smartphones,
  user: seller,
  status: :active,
  featured: true,
  stock_quantity: 30,
  weight: 0.232,
  dimensions: '163.4 x 78.1 x 8.6 mm',
  brand: 'Samsung'
)

macbook = Product.create!(
  name: 'MacBook Pro 14-inch',
  description: 'Powerful laptop with M3 Pro chip, perfect for professionals. Features Liquid Retina XDR display and up to 22 hours battery life.',
  price: 8999.00,
  sku: 'MACBOOK14',
  category: laptops,
  user: seller,
  status: :active,
  featured: true,
  stock_quantity: 20,
  weight: 1.55,
  dimensions: '312.6 x 221.2 x 15.5 mm',
  brand: 'Apple'
)

# Fashion products
men_shirt = Product.create!(
  name: 'Premium Cotton Shirt',
  description: 'High-quality cotton shirt perfect for formal and casual occasions. Available in multiple colors and sizes.',
  price: 89.90,
  sku: 'COTTONSHIRT',
  category: men_clothing,
  user: seller,
  status: :active,
  stock_quantity: 100,
  weight: 0.2,
  dimensions: 'Standard',
  brand: 'NEGO Fashion'
)

women_dress = Product.create!(
  name: 'Elegant Evening Dress',
  description: 'Beautiful evening dress perfect for special occasions. Made from premium fabric with elegant design.',
  price: 299.90,
  sku: 'EVENINGDRESS',
  category: women_clothing,
  user: seller,
  status: :active,
  stock_quantity: 25,
  weight: 0.5,
  dimensions: 'Standard',
  brand: 'NEGO Fashion'
)

# Health products
vitamin_c = Product.create!(
  name: 'Vitamin C 1000mg',
  description: 'High-potency Vitamin C supplement to support immune system and overall health. Halal certified.',
  price: 45.90,
  sku: 'VITAMINC1000',
  category: supplements,
  user: seller,
  status: :active,
  stock_quantity: 200,
  weight: 0.1,
  dimensions: 'Bottle',
  brand: 'HealthPlus'
)

moisturizer = Product.create!(
  name: 'Natural Face Moisturizer',
  description: 'Hydrating face moisturizer with natural ingredients. Suitable for all skin types. Halal certified.',
  price: 65.90,
  sku: 'MOISTURIZER',
  category: skincare,
  user: seller,
  status: :active,
  stock_quantity: 75,
  weight: 0.15,
  dimensions: 'Tube',
  brand: 'Natural Beauty'
)

# Food products
dates = Product.create!(
  name: 'Premium Medjool Dates',
  description: 'Sweet and nutritious Medjool dates from Saudi Arabia. Perfect for breaking fast or as a healthy snack.',
  price: 35.90,
  sku: 'MEDJOOLDATES',
  category: food,
  user: seller,
  status: :active,
  stock_quantity: 150,
  weight: 0.5,
  dimensions: 'Box',
  brand: 'Halal Foods'
)

# Create sample reviews
puts "Creating sample reviews..."
Review.create!(
  user: customer,
  product: iphone,
  rating: 5,
  comment: 'Excellent phone! The camera quality is amazing and the battery life is impressive.',
  status: :approved
)

Review.create!(
  user: customer,
  product: samsung_galaxy,
  rating: 4,
  comment: 'Great Android phone with lots of features. The S Pen is very useful.',
  status: :approved
)

Review.create!(
  user: customer,
  product: macbook,
  rating: 5,
  comment: 'Perfect for my work needs. Fast performance and great build quality.',
  status: :approved
)

# Create sample addresses
puts "Creating sample addresses..."
Address.create!(
  user: customer,
  label: 'Home',
  recipient_name: 'Test Customer',
  phone: '+60123456787',
  address_line1: '123 Jalan Ampang',
  address_line2: 'Ampang Heights',
  city: 'Kuala Lumpur',
  state: 'Kuala Lumpur',
  postal_code: '50450',
  country: 'Malaysia',
  is_default: true
)

Address.create!(
  user: customer,
  label: 'Office',
  recipient_name: 'Test Customer',
  phone: '+60123456787',
  address_line1: '456 Jalan Sultan Ismail',
  address_line2: 'Menara KL',
  city: 'Kuala Lumpur',
  state: 'Kuala Lumpur',
  postal_code: '50250',
  country: 'Malaysia',
  is_default: false
)

# Create sample coupons
puts "Creating sample coupons..."
Coupon.create!(
  code: 'WELCOME10',
  discount_type: :percentage,
  discount_value: 10.0,
  minimum_amount: 100.0,
  maximum_discount: 50.0,
  usage_limit: 1000,
  used_count: 0,
  valid_from: Time.current,
  valid_until: 1.month.from_now,
  status: :active
)

Coupon.create!(
  code: 'FLASH20',
  discount_type: :percentage,
  discount_value: 20.0,
  minimum_amount: 200.0,
  maximum_discount: 100.0,
  usage_limit: 500,
  used_count: 0,
  valid_from: Time.current,
  valid_until: 1.week.from_now,
  status: :active
)

puts "Seed data created successfully!"
puts "Admin user: admin@nego.com / password123"
puts "Seller user: seller@nego.com / password123"
puts "Customer user: customer@nego.com / password123"

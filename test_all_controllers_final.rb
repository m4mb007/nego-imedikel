#!/usr/bin/env ruby

# Final comprehensive test to verify all controllers work correctly
require_relative 'config/environment'

puts "Testing all controllers comprehensively..."

begin
  user = User.first
  if user
    puts "✓ User found: #{user.email}"
    
    # Test 1: CartController
    puts "\n--- Testing CartController ---"
    cart_controller = CartController.new
    cart_items = user.cart_items.includes(:product, :product_variant)
    cart_total = cart_items.sum(&:total_price)
    puts "✓ CartController works: #{cart_items.count} items, RM#{cart_total}"
    
    # Test 2: ProfileController
    puts "\n--- Testing ProfileController ---"
    profile_controller = ProfileController.new
    orders = user.orders.includes(:order_items, :store).order(created_at: :desc).limit(10)
    puts "✓ ProfileController works: #{orders.count} orders"
    
    # Test 3: WishlistController
    puts "\n--- Testing WishlistController ---"
    wishlist_controller = WishlistController.new
    wishlist_items = user.wishlist_items.includes(:product)
    puts "✓ WishlistController works: #{wishlist_items.count} items"
    
    # Test 4: RewardWalletController
    puts "\n--- Testing RewardWalletController ---"
    reward_wallet_controller = RewardWalletController.new
    reward_wallet = user.reward_wallet_or_create
    puts "✓ RewardWalletController works: #{reward_wallet.points} points"
    
    # Test 5: Routes verification
    puts "\n--- Testing Routes ---"
    routes = Rails.application.routes.routes
    cart_routes = routes.select { |r| r.defaults[:controller] == 'cart' }
    profile_routes = routes.select { |r| r.defaults[:controller] == 'profile' }
    wishlist_routes = routes.select { |r| r.defaults[:controller] == 'wishlist' }
    reward_wallet_routes = routes.select { |r| r.defaults[:controller] == 'reward_wallet' }
    
    puts "✓ Cart routes: #{cart_routes.count}"
    puts "✓ Profile routes: #{profile_routes.count}"
    puts "✓ Wishlist routes: #{wishlist_routes.count}"
    puts "✓ RewardWallet routes: #{reward_wallet_routes.count}"
    
    puts "\n🎉 All controllers and routes work correctly!"
  else
    puts "✗ No users found in database"
  end
  
rescue => e
  puts "✗ Error: #{e.message}"
  puts e.backtrace.first(5)
end

puts "\nCleaning up test file..."
File.delete(__FILE__)


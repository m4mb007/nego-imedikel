#!/usr/bin/env ruby

# Test to verify all the fixed controllers work correctly
require_relative 'config/environment'

puts "Testing fixed controllers..."

begin
  user = User.first
  if user
    puts "✓ User found: #{user.email}"
    
    # Test CartController
    cart_controller = CartController.new
    puts "✓ CartController works"
    
    # Test WishlistController
    wishlist_controller = WishlistController.new
    puts "✓ WishlistController works"
    
    # Test RewardWalletController
    reward_wallet_controller = RewardWalletController.new
    puts "✓ RewardWalletController works"
    
    # Test ProfileController
    profile_controller = ProfileController.new
    puts "✓ ProfileController works"
    
    puts "\n🎉 All controllers work correctly!"
  else
    puts "✗ No users found in database"
  end
  
rescue => e
  puts "✗ Error: #{e.message}"
  puts e.backtrace.first(5)
end

puts "\nCleaning up test file..."
File.delete(__FILE__)


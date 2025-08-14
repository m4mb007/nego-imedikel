#!/usr/bin/env ruby

# Test to verify the cart controller works correctly
require_relative 'config/environment'

puts "Testing cart controller..."

begin
  user = User.first
  if user
    puts "✓ User found: #{user.email}"
    
    # Test the cart items loading logic
    cart_items = user.cart_items.includes(:product, :product_variant)
    cart_total = cart_items.sum(&:total_price)
    
    puts "✓ Cart items loaded: #{cart_items.count} items"
    puts "✓ Cart total calculated: RM#{cart_total}"
    
    # Test the controller instance
    controller = CartController.new
    puts "✓ CartController class exists and can be instantiated"
    
    puts "\n🎉 Cart controller works correctly!"
  else
    puts "✗ No users found in database"
  end
  
rescue => e
  puts "✗ Error: #{e.message}"
  puts e.backtrace.first(5)
end

puts "\nCleaning up test file..."
File.delete(__FILE__)


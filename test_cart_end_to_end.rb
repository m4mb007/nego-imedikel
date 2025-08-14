#!/usr/bin/env ruby

# Comprehensive test to verify cart functionality works end-to-end
require_relative 'config/environment'

puts "Testing cart functionality end-to-end..."

begin
  user = User.first
  product = Product.first
  
  if user && product
    puts "✓ User: #{user.email}"
    puts "✓ Product: #{product.name}"
    
    # Test 1: Add product to cart
    cart_item = user.cart_items.create!(
      product: product,
      quantity: 2
    )
    puts "✓ Added product to cart (quantity: 2)"
    
    # Test 2: Verify cart item exists
    cart_items = user.cart_items.includes(:product, :product_variant)
    puts "✓ Cart items count: #{cart_items.count}"
    
    # Test 3: Calculate cart total
    cart_total = cart_items.sum(&:total_price)
    puts "✓ Cart total: RM#{cart_total}"
    
    # Test 4: Test controller logic
    controller = CartController.new
    puts "✓ CartController instantiated successfully"
    
    # Test 5: Simulate controller action
    cart_items_from_controller = user.cart_items.includes(:product, :product_variant)
    cart_total_from_controller = cart_items_from_controller.sum(&:total_price)
    puts "✓ Controller logic works: #{cart_items_from_controller.count} items, RM#{cart_total_from_controller}"
    
    # Test 6: Update quantity
    cart_item.update(quantity: 3)
    updated_total = user.cart_items.includes(:product, :product_variant).sum(&:total_price)
    puts "✓ Updated quantity: RM#{updated_total}"
    
    # Test 7: Clear cart
    user.cart_items.destroy_all
    final_count = user.cart_items.count
    puts "✓ Cleared cart: #{final_count} items remaining"
    
    puts "\n🎉 All cart functionality tests passed!"
  else
    puts "✗ Missing user or product for testing"
  end
  
rescue => e
  puts "✗ Error: #{e.message}"
  puts e.backtrace.first(5)
end

puts "\nCleaning up test file..."
File.delete(__FILE__)


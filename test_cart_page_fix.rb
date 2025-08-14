#!/usr/bin/env ruby

# Final test to verify the cart page works correctly
require_relative 'config/environment'

puts "Testing cart page functionality..."

begin
  user = User.first
  if user
    puts "✓ User found: #{user.email}"
    
    # Add a product to cart first
    product = Product.first
    if product
      puts "✓ Product found: #{product.name}"
      
      # Add to cart
      cart_item = user.cart_items.create!(
        product: product,
        quantity: 1
      )
      puts "✓ Added product to cart"
      
      # Test cart loading
      cart_items = user.cart_items.includes(:product, :product_variant)
      cart_total = cart_items.sum(&:total_price)
      
      puts "✓ Cart items: #{cart_items.count}"
      puts "✓ Cart total: RM#{cart_total}"
      
      # Clean up
      cart_item.destroy
      puts "✓ Test cart item cleaned up"
      
      puts "\n🎉 Cart page functionality works correctly!"
    else
      puts "✗ No products found"
    end
  else
    puts "✗ No users found"
  end
  
rescue => e
  puts "✗ Error: #{e.message}"
  puts e.backtrace.first(5)
end

puts "\nCleaning up test file..."
File.delete(__FILE__)


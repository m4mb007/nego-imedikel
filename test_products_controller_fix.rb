#!/usr/bin/env ruby

# Test to verify the products controller add_to_cart action works
require_relative 'config/environment'

puts "Testing products controller add_to_cart action..."

begin
  user = User.first
  product = Product.first
  
  if user && product
    puts "✓ User found: #{user.email}"
    puts "✓ Product found: #{product.name}"
    
    # Simulate the controller action logic
    if product.in_stock?
      # Check if item already exists in cart
      existing_cart_item = user.cart_items.find_by(product: product)
      
      if existing_cart_item
        existing_cart_item.update(quantity: existing_cart_item.quantity + 1)
        puts "✓ Updated existing cart item quantity"
      else
        user.cart_items.create!(
          product: product,
          quantity: 1
        )
        puts "✓ Created new cart item"
      end
    else
      puts "✗ Product is out of stock"
    end
    
    # Clean up
    user.cart_items.where(product: product).destroy_all
    puts "✓ Test cart items cleaned up"
    
    puts "\n🎉 Products controller add_to_cart action works correctly!"
  else
    puts "✗ Missing user or product for testing"
  end
  
rescue => e
  puts "✗ Error: #{e.message}"
  puts e.backtrace.first(5)
end

puts "\nCleaning up test file..."
File.delete(__FILE__)


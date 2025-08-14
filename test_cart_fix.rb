#!/usr/bin/env ruby

# Test to verify the cart fix works
require_relative 'config/environment'

puts "Testing cart fix..."

begin
  user = User.first
  product = Product.first
  
  if user && product
    puts "✓ User found: #{user.email}"
    puts "✓ Product found: #{product.name}"
    
    # Test creating a cart item without product_variant_id
    cart_item = user.cart_items.create!(
      product: product,
      quantity: 1
    )
    
    puts "✓ Cart item created successfully: #{cart_item.id}"
    puts "✓ product_variant_id is: #{cart_item.product_variant_id.inspect}"
    
    # Clean up
    cart_item.destroy
    puts "✓ Test cart item cleaned up"
    
    puts "\n🎉 Cart fix works correctly!"
  else
    puts "✗ Missing user or product for testing"
  end
  
rescue => e
  puts "✗ Error: #{e.message}"
  puts e.backtrace.first(5)
end

puts "\nCleaning up test file..."
File.delete(__FILE__)


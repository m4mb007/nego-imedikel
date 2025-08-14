#!/usr/bin/env ruby

# Simple test to verify the recent scope works
require_relative 'config/environment'

puts "Testing Referral.recent scope..."

begin
  # Test the recent scope directly
  recent_referrals = Referral.recent
  puts "✓ Referral.recent scope works: #{recent_referrals.count} referrals found"
  
  # Test it through the association
  user = User.first
  if user
    user_recent_referrals = user.referred_users.recent
    puts "✓ user.referred_users.recent works: #{user_recent_referrals.count} referrals found"
  end
  
  puts "\n🎉 Recent scope test passed!"
  
rescue => e
  puts "✗ Error: #{e.message}"
  puts e.backtrace.first(3)
end

puts "\nCleaning up test file..."
File.delete(__FILE__)

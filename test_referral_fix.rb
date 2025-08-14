#!/usr/bin/env ruby

# Temporary test file to verify referral controller fix
require_relative 'config/environment'

puts "Testing referral controller fix..."

begin
  user = User.first
  if user
    puts "✓ User found: #{user.email}"
    
    # Test earned_commissions.recent
    commissions = user.earned_commissions.includes(:user, :order).recent.limit(10)
    puts "✓ earned_commissions.recent works: #{commissions.count} commissions found"
    
    # Test referred_users.recent
    referrals = user.referred_users.includes(:user).recent.limit(10)
    puts "✓ referred_users.recent works: #{referrals.count} referrals found"
    
    puts "\n🎉 All tests passed! The referral controller should now work correctly."
  else
    puts "✗ No users found in database"
  end
rescue => e
  puts "✗ Error: #{e.message}"
  puts e.backtrace.first(5)
end

puts "\nCleaning up test file..."
File.delete(__FILE__)

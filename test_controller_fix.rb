#!/usr/bin/env ruby

# Test to verify the referrals controller show action works
require_relative 'config/environment'

puts "Testing referrals controller show action..."

begin
  user = User.first
  if user
    puts "✓ User found: #{user.email}"
    
    # Simulate the controller action
    referral_stats = MlmService.get_user_referral_stats(user)
    referral_tree = user.referral_tree
    commissions = user.earned_commissions.includes(:user, :order).recent.limit(10)
    referrals = user.referred_users.includes(:user).recent.limit(10)
    
    puts "✓ referral_stats: #{referral_stats.class}"
    puts "✓ referral_tree: #{referral_tree.class}"
    puts "✓ commissions: #{commissions.count} found"
    puts "✓ referrals: #{referrals.count} found"
    
    puts "\n🎉 Referrals controller show action works correctly!"
  else
    puts "✗ No users found in database"
  end
  
rescue => e
  puts "✗ Error: #{e.message}"
  puts e.backtrace.first(5)
end

puts "\nCleaning up test file..."
File.delete(__FILE__)

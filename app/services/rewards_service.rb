class RewardsService
  class << self
    # Getter methods for configuration from database
    def points_per_ringgit
      Setting.get('points_per_ringgit', 1).to_f
    end

    def redemption_percentage
      Setting.get('redemption_percentage', 20).to_f
    end

    def points_to_ringgit_ratio
      Setting.get('points_to_ringgit_ratio', 100).to_f
    end

    def min_redemption_amount
      Setting.get('min_redemption_amount', 100).to_i
    end

    def rewards_enabled?
      Setting.get('rewards_enabled', 'true') == 'true'
    end

    # Update configuration in database
    def update_config(config = {})
      config.each do |key, value|
        Setting.set(key.to_s, value.to_s)
      end
    end
  end

  class << self
    def calculate_points_for_order(order)
      return 0 unless order.completed?
      
      # Calculate points based on order total (excluding shipping and taxes)
      subtotal = order.subtotal
      (subtotal * points_per_ringgit).to_i
    end

    def award_points_for_order(order)
      points = calculate_points_for_order(order)
      return false if points <= 0

      user = order.user
      description = "Points earned from order ##{order.id}"
      
      user.add_points(points, description, order)
    end

    def calculate_max_redemption_amount(order_total, user_points)
      max_points = (order_total * redemption_percentage / 100.0 * points_to_ringgit_ratio).to_i
      [max_points, user_points].min
    end

    def calculate_redemption_discount(points_to_redeem)
      (points_to_redeem / points_to_ringgit_ratio.to_f).round(2)
    end

    def can_redeem_points?(user_points, order_total, points_to_redeem)
      return false if points_to_redeem < min_redemption_amount
      return false if points_to_redeem > user_points
      
      max_redemption = calculate_max_redemption_amount(order_total, user_points)
      points_to_redeem <= max_redemption
    end

    def redeem_points_for_order(user, points_to_redeem, order)
      return false unless can_redeem_points?(user.points_balance, order.total_amount, points_to_redeem)
      
      description = "Points redeemed for order ##{order.id}"
      user.deduct_points(points_to_redeem, description, order)
    end

    def get_rewards_config
      {
        points_per_ringgit: points_per_ringgit,
        redemption_percentage: redemption_percentage,
        points_to_ringgit_ratio: points_to_ringgit_ratio,
        min_redemption_amount: min_redemption_amount,
        rewards_enabled: rewards_enabled?
      }
    end

    def format_points(points)
      "#{points} points"
    end

    def format_points_value(points)
      value = calculate_redemption_discount(points)
      "RM#{value}"
    end
  end
end

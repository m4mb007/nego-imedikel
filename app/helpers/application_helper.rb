module ApplicationHelper
  def get_order_status_class(status)
    case status.to_s
    when 'pending'
      'order-status-pending'
    when 'confirmed'
      'order-status-confirmed'
    when 'processing'
      'order-status-processing'
    when 'shipped'
      'order-status-shipped'
    when 'delivered'
      'order-status-delivered'
    when 'cancelled'
      'order-status-cancelled'
    when 'refunded'
      'order-status-refunded'
    else
      'bg-gray-100 text-gray-800'
    end
  end
end

class Address < ApplicationRecord
  belongs_to :user

  validates :recipient_name, presence: true
  validates :phone, presence: true
  validates :address_line1, presence: true
  validates :city, presence: true
  validates :state, presence: true
  validates :postal_code, presence: true
  validates :country, presence: true

  def full_name
    recipient_name
  end

  def street_address
    [address_line1, address_line2].compact.join(', ')
  end

  def full_address
    [street_address, city, state, postal_code, country].compact.join(', ')
  end
end

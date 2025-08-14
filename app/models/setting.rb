class Setting < ApplicationRecord
  validates :key, presence: true, uniqueness: true
  validates :value, presence: true
  
  def self.get(key, default = nil)
    setting = find_by(key: key)
    setting&.value || default
  end
  
  def self.set(key, value)
    setting = find_or_initialize_by(key: key)
    setting.value = value
    setting.save
  end
end

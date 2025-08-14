class Admin::SettingsController < ApplicationController
  before_action :require_admin

  def index
    @settings = Setting.all.index_by(&:key)
  end

  def update
    params[:settings].each do |key, value|
      setting = Setting.find_or_initialize_by(key: key)
      setting.value = value
      setting.save
    end
    
    redirect_to admin_settings_path, notice: 'Settings updated successfully.'
  end
end

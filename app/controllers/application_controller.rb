class ApplicationController < ActionController::Base
  include Pundit::Authorization
  
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_locale
  before_action :set_cart_count
  
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :phone, :role])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :phone])
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def set_cart_count
    @cart_count = current_user&.cart_items_count || 0
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end

  def require_seller
    unless current_user&.seller?
      flash[:alert] = "You need to be a seller to access this page."
      redirect_to root_path
    end
  end

  def require_admin
    unless current_user&.admin?
      flash[:alert] = "You need to be an admin to access this page."
      redirect_to root_path
    end
  end

  def require_store
    unless current_user&.has_store?
      flash[:alert] = "You need to create a store first."
      redirect_to new_store_path
    end
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_dashboard_path
    elsif resource.seller?
      seller_dashboard_path
    else
      root_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  private

  def default_url_options
    { locale: I18n.locale == I18n.default_locale ? nil : I18n.locale }
  end
end

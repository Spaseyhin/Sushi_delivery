# frozen_string_literal: true

# ApplicationController is the base controller for the application.
# It provides helper methods and before actions for handling user sessions,
# cart management, and items in the cart.
#
# Actions:
# - `current_user`: Returns the current logged-in user.
# - `logged_in?`: Returns true if there is a logged-in user, otherwise false.
# - `current_cart`: Returns the current cart for the user or guest.
# - `load_cart_items`: Loads all cart items, calculates the total price, and sets up necessary cart-related data.
#
class ApplicationController < ActionController::Base
  helper_method :current_user, :current_cart, :logged_in?, :load_cart_items
  before_action :load_cart_items
  before_action :set_locale

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(AdminUser)
      admin_products_path(locale: I18n.locale)
    else
      super
    end
  end

  def current_cart
    @current_cart ||= Cart.for(user: current_user, session: session)
  end

  private

  def load_cart_items
    @cart = current_cart
    @cart_items = @cart.items
    @cart_items_count = @cart.total_quantity
    @cart_total_price = @cart.total_price
    @cart_items_hash = @cart_items.index_by(&:product_id).transform_values(&:quantity)
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end
end

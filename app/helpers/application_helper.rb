# frozen_string_literal: true

# The ApplicationHelper module provides utility methods
# that can be used across views in the application.
module ApplicationHelper
  def cart_items_count
    session[:cart]&.values&.sum || 0
  end
end

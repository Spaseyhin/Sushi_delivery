# frozen_string_literal: true

# CartsController is responsible for displaying the shopping cart.
#
# This controller allows users to view the contents of their cart.
# It supports both standard HTML views and Turbo Streams for real-time updates.
class CartsController < ApplicationController
  # Displays the current user's cart.
  #
  # This action loads all the items in the cart, calculates the total price,
  # and responds with either a regular HTML view or a Turbo Stream update.
  #
  # @return [void]
  def show
    load_cart_items

    respond_to do |format|
      format.html
      format.turbo_stream { render_turbo_cart_response }
    end
  end

  private

  def render_turbo_cart_response
    if @cart_items.any?
      render partial: 'carts/cart_frame', formats: [:html],
             locals: { cart_items: @cart_items, cart_total_price: @cart_total_price }
    else
      head :no_content
    end
  end
end

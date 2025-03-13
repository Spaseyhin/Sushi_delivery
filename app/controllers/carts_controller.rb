class CartsController < ApplicationController
  def show
    load_cart_items

    respond_to do |format|
      format.html
      format.turbo_stream do
        render partial: 'carts/cart_frame', formats: [:html],
               locals: { cart_items: @cart_items, cart_total_price: @cart_total_price }
      end
    end
  end
end

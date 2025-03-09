class CartsController < ApplicationController
  def show
    @cart = current_cart
    @cart_items = @cart.cart_items.includes(:product) # Загружаем товары
    @total_price = @cart_items.sum { |item| item.product.price * item.quantity }
  end

  private

  def current_cart
    @current_cart ||= Cart.find_or_create_by(user: current_user)
  end
end

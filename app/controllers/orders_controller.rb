# frozen_string_literal: true

# OrdersController is responsible for managing orders placed by the users.
#
# This controller handles the creation and listing of orders, and processes the checkout process for the user.
# It ensures that the user has items in the cart before allowing them to place an order.
class OrdersController < ApplicationController
  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def create
    Order.create_from_cart!(current_user, current_cart)

    session.delete(:order_now)
    redirect_to orders_path, notice: t('order.successfully_order')
  rescue ArgumentError
    redirect_to cart_path, alert: t('order.cart_empty')
  rescue StandardError
    redirect_to cart_path, alert: t('order.error')
  end
end

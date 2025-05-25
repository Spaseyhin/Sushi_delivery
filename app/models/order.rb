# frozen_string_literal: true

# Order represents a user's order in the system.
# It contains the details of the order, the user who placed it, and its associated order items.
#
# Associations:
# - belongs_to :user: Associates the order with a specific user.
# - has_many :order_items, dependent: :destroy: An order can have many order items, which are destroyed when the order
#  is deleted.
#
# Callbacks:
# - after_create_commit: After an order is created, it broadcasts the new order to the 'orders' channel,
#   prepending it to the target element 'orders' in the admin view, using the 'admin/orders/order' partial.
class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  after_create_commit lambda {
    broadcast_prepend_later_to 'orders',
                               target: 'orders',
                               partial: 'admin/orders/order',
                               locals: { order: self }
  }

  # Создаёт заказ из корзины пользователя
  def self.create_from_cart!(user, cart)
    raise ArgumentError, I18n.t('order.cart_empty') if cart.cart_items.empty?

    transaction do
      order = create_order_for_user!(user, cart)
      add_items_to_order!(order, cart)
      clear_cart_items!(cart)
      order
    end
  end

  # Создаёт новый заказ для пользователя
  def self.create_order_for_user!(user, cart)
    user.orders.create!(
      total_price: cart_total_price(cart),
      order_number: next_order_number(user)
    )
  end

  # Добавляет товары из корзины в заказ
  def self.add_items_to_order!(order, cart)
    # Используем includes для оптимизации запросов
    # чтобы избежать N+1 проблемы
    # и используем find_each для обработки больших объёмов данных
    # чтобы избежать проблем с памятью

    cart.cart_items.includes(:product).find_each do |item|
      order.order_items.create!(
        product: item.product,
        quantity: item.quantity,
        price: item.product.price
      )
    end
  end

  # Очищает корзину пользователя
  def self.clear_cart_items!(cart)
    cart.cart_items.destroy_all
  end

  # Возвращает общую стоимость заказа
  def self.cart_total_price(cart)
    cart.cart_items.includes(:product).sum { |item| item.product.price * item.quantity }
  end

  def self.next_order_number(user)
    (user.orders.maximum(:order_number) || 0) + 1
  end
end

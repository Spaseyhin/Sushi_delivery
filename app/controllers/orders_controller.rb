class OrdersController < ApplicationController
  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def create
    @cart = current_cart

    # Проверка: если корзина пуста, не оформляем заказ
    if @cart.cart_items.empty?
      redirect_to cart_path, alert: 'Ваша корзина пуста. Пожалуйста, добавьте товары перед оформлением заказа.'
      return
    end

    total_price = @cart.cart_items.includes(:product).sum { |item| item.product.price * item.quantity }

    # Считаем следующий номер заказа для пользователя
    next_order_number = current_user.orders.maximum(:order_number).to_i + 1

    # Создаем заказ
    @order = current_user.orders.build(total_price: total_price, order_number: next_order_number)

    if @order.save
      # Копируем товары из корзины в заказ
      @cart.cart_items.each do |cart_item|
        @order.order_items.create!(
          product: cart_item.product,
          quantity: cart_item.quantity,
          price: cart_item.product.price
        )
      end

      @cart.cart_items.destroy_all # очищаем корзину после оформления заказа
      session.delete(:order_now) # удаляем метку о намерении оформить заказ

      redirect_to orders_path,
                  notice: 'Спасибо за заказ! Оператор в скором времени с вами свяжется для уточнения заказа'
    else
      redirect_to cart_path, alert: 'Произошла ошибка при оформлении заказа. Попробуйте снова.'
    end
  end
end

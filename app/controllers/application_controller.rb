# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper_method :current_user, :current_cart, :logged_in?, :load_cart_items
  before_action :load_cart_items

  # Получить текущего пользователя
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # Проверка на вход
  def logged_in?
    current_user.present?
  end

  # Правильная корзина
  def current_cart
    @current_cart ||= find_or_create_cart
  end

  private

  # Правильная логика поиска/создания корзины
  def find_or_create_cart
    if logged_in?
      # Если есть пользователь, ищем или создаем привязанную к нему корзину
      current_user.cart || current_user.create_cart
    elsif session[:cart_id]
      # Если гость — через сессию
      Cart.find_by(id: session[:cart_id]) || create_guest_cart
    else
      create_guest_cart
    end
  end

  # Создание корзины для гостя (анонимной)
  def create_guest_cart
    cart = Cart.create
    session[:cart_id] = cart.id if cart.persisted?
    Rails.logger.info "=== Создана корзина с id: #{cart.id}, ошибки: #{cart.errors.full_messages} ==="
    cart
  end

  def load_cart_items
    @cart = current_cart
    @cart_items = @cart.cart_items.includes(product: [image_attachment: :blob]).joins(:product).order('products.name ASC') # по алфавиту
    @cart_items_count = @cart.cart_items.sum(:quantity)
    @cart_total_price = @cart_items.sum { |item| item.product.price * item.quantity }

    # Новый хэш для удобного поиска количества товара
    @cart_items_hash = @cart_items.each_with_object({}) do |item, hash|
      hash[item.product_id] = item.quantity
    end
  end
end

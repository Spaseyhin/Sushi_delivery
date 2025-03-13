# frozen_string_literal: true

# Контроллер `UsersController` управляет процессом аутентификации пользователей через OTP-коды.
# - `create` → Генерирует и отправляет OTP пользователю.
# - `verify` → Проверяет введённый OTP и авторизует пользователя.
# - `logout` → Завершает сеанс пользователя.
#
# OTP хранится в базе данных и удаляется после успешной проверки или истечения срока.
class UsersController < ApplicationController
  before_action :set_user, only: %i[create verify]

  def new
    @user = User.new
  end

  # Создаёт и отправляет OTP пользователю
  def create
    @user.generate_confirmation_code!
    Rails.logger.info "✅ Сгенерирован OTP для #{@user.phone_number}: #{@user.confirmation_code}"

    respond_to do |format|
      format.turbo_stream { render partial: 'users/create', locals: { user: @user } }
    end
  end

  # Проверяет введённый OTP и авторизует пользователя
  def verify
    if @user.verify(params[:confirmation_code]) # Проверяем код через модель
      log_in_user
    else
      handle_invalid_otp
    end
  end

  # Выход пользователя
  def logout
    session.delete(:user_id)    # Удаляем ID пользователя из сессии
    session.delete(:cart_id)    # Удаляем корзину пользователя (очищаем текущую корзину)

    redirect_to root_path # Возвращаем на главную (и там создается новая корзина)
  end

  private

  # Ищем пользователя по номеру телефона
  def set_user
    @user = User.find_or_create_by(phone_number: params[:phone_number])
  end

  # Авторизует пользователя
  # Авторизует пользователя
  def log_in_user
    session[:user_id] = @user.id

    guest_cart = Cart.find_by(id: session[:cart_id]) # Гостевая корзина

    # Создаем корзину для пользователя, если нет
    user_cart = @user.cart || @user.create_cart

    if guest_cart && guest_cart.cart_items.any?
      # Переносим товары из гостевой корзины в корзину пользователя
      guest_cart.cart_items.each do |item|
        existing_item = user_cart.cart_items.find_by(product_id: item.product_id)

        if existing_item
          # Если товар уже есть в корзине пользователя — увеличиваем количество
          existing_item.update(quantity: existing_item.quantity + item.quantity)
        else
          # Если товара нет — добавляем
          user_cart.cart_items.create(product_id: item.product_id, quantity: item.quantity)
        end
      end

      # Удаляем гостевую корзину
      guest_cart.destroy

      Rails.logger.info '✅ Товары из гостевой корзины перенесены и корзина удалена'
    end

    # Привязываем корзину пользователя к сессии
    session[:cart_id] = user_cart.id

    redirect_to root_path
  end

  # Обрабатывает неверный код
  def handle_invalid_otp
    flash.now[:alert] = I18n.t('users.otp_invalid')
    Rails.logger.info '❌ Ошибка: неверный код! Отправляем Turbo Stream.'

    respond_to do |format|
      format.turbo_stream { render partial: 'users/create', locals: { user: @user } }
    end
  end
end

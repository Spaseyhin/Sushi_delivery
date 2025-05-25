# frozen_string_literal: true

# Контроллер `UsersController` управляет процессом аутентификации пользователей через OTP-коды.
# - `create` → Генерирует и отправляет OTP пользователю.
# - `verify` → Проверяет введённый OTP и авторизует пользователя.
# - `logout` → Завершает сеанс пользователя.
#
# OTP хранится в базе данных и удаляется после успешной проверки или истечения срока.
class UsersController < ApplicationController
  before_action :set_user, only: %i[create verify]
  before_action :authenticate_user!, only: %i[address update_address] # Проверка на вход

  def new
    session[:order_now] = params[:order_now] if params[:order_now].present?
    @user = User.new
  end

  # Создаёт и отправляет OTP пользователю
  def create
    @user.generate_confirmation_code!
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

  # ➤ Форма адреса
  # ⚙️ Новый экшен для показа формы адреса
  def address
    @user = current_user
  end

  # Обновить адрес
  def update_address
    if current_user.update(user_params)
      process_order_if_needed # Проверяем и создаем заказ, если нужно
    else
      flash.now[:alert] = t('users.address_save_error')
      render :edit
    end
  end

  # Проверить нужно ли оформлять заказ
  def process_order_if_needed
    if session[:order_now] && current_cart.cart_items.any?
      session.delete(:order_now)

      Order.create_from_cart!(current_user, current_cart)

      redirect_to orders_path, notice: t('orders.success_message')
    else
      redirect_to root_path
    end
  end

  private

  def user_params
    params.require(:user).permit(:address)
  end

  # Ищем пользователя по номеру телефона
  def set_user
    @user = User.find_or_initialize_by_phone(params[:phone_number])
  end

  # Авторизация пользователя

  def create_cart
    @user_cart = @user.cart || @user.create_cart
  end

  def redirect_unless_address_present
    if @user.address.blank?
      redirect_to address_users_path #  если нет адреса — перенаправляем на ввод
    else
      redirect_to root_path # иначе на главную
    end
  end

  def log_in_user
    @user.log_in!(session)
    redirect_unless_address_present
  end

  # Обрабатывает неверный код
  def handle_invalid_otp
    flash.now[:alert] = t('users.otp_invalid')
    respond_to do |format|
      format.turbo_stream { render partial: 'users/create', locals: { user: @user } }
    end
  end

  # ➤ Проверка входа пользователя
  def authenticate_user!
    redirect_to new_user_path unless current_user
  end
end

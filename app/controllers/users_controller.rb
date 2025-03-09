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
    session.delete(:user_id)
    flash[:notice] = I18n.t('users.logout_success')
    redirect_to root_path
  end

  private

  # Ищем пользователя по номеру телефона
  def set_user
    @user = User.find_or_create_by(phone_number: params[:phone_number])
  end

  # Авторизует пользователя
  def log_in_user
    session[:user_id] = @user.id
    flash[:notice] = I18n.t('users.otp_verified')
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

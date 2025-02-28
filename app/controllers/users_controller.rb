# frozen_string_literal: true

# UsersController управляет процессом аутентификации пользователей через OTP (одноразовый пароль).
# - `create` → Генерирует и отправляет OTP пользователю.
# - `verify` → Проверяет введённый OTP и авторизует пользователя.
# - `logout` → Завершает сеанс пользователя.
#
# OTP хранится в `session` и удаляется после успешной проверки или истечения срока.
class UsersController < ApplicationController
  before_action :find_or_create_user, only: %i[create verify]
  def new
    @user = User.new
  end

  def create
    phone_number = params[:phone_number]
    generate_otp(phone_number)

    respond_to do |format|
      format.turbo_stream { render partial: 'users/create' }
    end
  end

  def verify
    phone_number = params[:phone_number]

    return handle_expired_otp(phone_number) if otp_expired?(phone_number)

    return log_in_user(phone_number) if valid_otp?(phone_number, params[:confirmation_code]) # Блок 2

    handle_invalid_otp # Блок 3 (вызывается, если предыдущие не сработали)
  end

  def logout
    session.delete(:user_id) # Удаляем сессию пользователя
    flash[:notice] = I18n.t('users.logout_success')
    redirect_to root_path
  end

  def find_or_create_user
    @user = User.find_or_create_by(phone_number: params[:phone_number])
  end

  private

  # Генерирует OTP и сохраняет его в сессии
  def generate_otp(phone_number)
    session[:otp_codes] ||= {}
    session[:otp_expires] ||= {}

    otp_code = rand(1000..9999).to_s
    session[:otp_codes][phone_number] = otp_code
    session[:otp_expires][phone_number] = 5.minutes.from_now

    Rails.logger.info "Generated OTP for #{phone_number}: #{otp_code}" # Логируем код
  end

  # Обрабатывает случай, если OTP-код истёк
  def handle_expired_otp(phone_number)
    flash[:alert] = I18n.t('users.otp_expired') # "OTP code has expired!"
    clear_otp(phone_number) # Удаляем старый OTP перед редиректом
    redirect_to root_path
  end

  # Проверяет, истёк ли OTP-код
  def otp_expired?(phone_number)
    expires_at = session.dig(:otp_expires, phone_number)
    expires_at && expires_at < Time.current
  end

  # Авторизует пользователя
  def log_in_user(phone_number)
    session[:user_id] = @user.id
    clear_otp(phone_number) # Используем новый метод для удаления OTP

    flash[:notice] = I18n.t('users.otp_verified') # "Successfully verified!"
    redirect_to root_path
  end

  # Удаляет OTP-код и его срок действия из сессии
  def clear_otp(phone_number)
    session[:otp_codes]&.delete(phone_number)
    session[:otp_expires]&.delete(phone_number)
  end

  # Проверяет, совпадает ли введённый пользователем OTP с сохранённым
  def valid_otp?(phone_number, entered_code)
    stored_code = session.dig(:otp_codes, phone_number)
    stored_code.present? && ActiveSupport::SecurityUtils.secure_compare(stored_code, entered_code)
  end

  # Обрабатывает случай, если OTP неверный
  def handle_invalid_otp
    respond_to do |format|
      @error_message = I18n.t('users.otp_invalid') # "Invalid code! Try again."
      format.turbo_stream { render partial: 'users/create' }
    end
  end

  def user_params
    params.require(:user).permit(:phone_number)
  end
end

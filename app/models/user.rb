# frozen_string_literal: true

# Класс User представляет пользователей системы и отвечает за:
# - Хранение номера телефона (`phone_number`)
# - Генерацию и валидацию OTP-кодов (`generate_confirmation_code!`, `valid_confirmation_code?`)
# - Верификацию пользователя (`verify`)
class User < ApplicationRecord
  has_one :cart, dependent: :destroy
  validates :phone_number, presence: true, uniqueness: true
  validates :confirmation_code, length: { is: 4 }, allow_nil: true

  #  Метод, который генерирует новый код подтверждения и обновляет время его отправки
  def generate_confirmation_code!
    update!(
      confirmation_code: rand(1000..9999).to_s, # Генерируем случайное 4-значное число и сохраняем как строку
      confirmation_code_sent_at: Time.current # Запоминаем, когда код был отправлен
    )
  end

  #  Метод, проверяющий, действителен ли код подтверждения
  def valid_confirmation_code?(code)
    return false if confirmation_code.nil? || confirmation_code_sent_at < 10.minutes.ago

    # Если код отсутствует или срок его действия истёк (старше 10 минут) → false

    confirmation_code == code # Возвращаем true, если введённый код совпадает с тем, что в БД
  end

  #  Метод верификации пользователя
  # Принимает введённый пользователем код и проверяет его
  def verify(code)
    return false unless valid_confirmation_code?(code) # Если код неверный или устарел → возвращаем false

    update!(confirmation_code: nil) # Если код верный, очищаем его из базы (чтобы нельзя было использовать повторно)
    true # Возвращаем true, чтобы контроллер знал, что проверка успешна
  end

  private

  # Удаляет OTP-код и его срок действия из сессии
  def clear_otp(phone_number)
    session[:otp_codes]&.delete(phone_number)
    session[:otp_expires]&.delete(phone_number)
  end
end

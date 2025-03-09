# frozen_string_literal: true

# Создаёт таблицу users для хранения пользователей и их OTP-кодов.
#
# Поля:
# - `phone_number` (string) – номер телефона пользователя
# - `confirmation_code` (string) – код подтверждения (OTP)
# - `confirmation_code_sent_at` (datetime) – время отправки OTP-кода
# - `timestamps` – стандартные временные метки (created_at, updated_at)
class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :phone_number
      t.string :confirmation_code
      t.datetime :confirmation_code_sent_at

      t.timestamps
    end
    add_index :users, :phone_number, unique: true #  Добавляем уникальный индекс
  end
end

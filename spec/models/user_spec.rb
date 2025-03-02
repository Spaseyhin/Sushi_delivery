# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  let(:user) { create(:user) } # Используем FactoryBot для создания пользователя

  describe 'валидации' do
    it 'валиден с корректным номером телефона' do
      expect(user).to be_valid
    end

    it 'невалиден без номера телефона' do
      user.phone_number = nil
      expect(user).not_to be_valid
    end

    it 'не позволяет создавать пользователей с одинаковыми номерами' do
      user1 = create(:user) # Первый пользователь с уникальным номером
      user2 = build(:user, phone_number: user1.phone_number) # Создаём второго с таким же номером
      expect(user2).not_to be_valid
    end
  end

  describe '#generate_confirmation_code!' do
    it 'генерирует 4-значный код и сохраняет его' do
      user.generate_confirmation_code!
      expect(user.confirmation_code).to match(/\A\d{4}\z/)
    end

    it 'обновляет время отправки кода' do
      old_time = user.confirmation_code_sent_at
      user.generate_confirmation_code!
      expect(user.confirmation_code_sent_at).not_to eq(old_time)
    end
  end

  describe '#valid_confirmation_code?' do
    before { user.generate_confirmation_code! }

    it 'возвращает true для верного кода' do
      expect(user.valid_confirmation_code?(user.confirmation_code)).to be true
    end

    it 'возвращает false для неверного кода' do
      expect(user.valid_confirmation_code?('0000')).to be false
    end

    it 'возвращает false, если код устарел' do
      user.update(confirmation_code_sent_at: 11.minutes.ago)
      expect(user.valid_confirmation_code?(user.confirmation_code)).to be false
    end
  end

  describe '#verify' do
    before { user.generate_confirmation_code! }

    it 'возвращает true при правильном коде' do
      expect(user.verify(user.confirmation_code)).to be true
    end

    it 'очищает код после верификации' do
      user.verify(user.confirmation_code)
      expect(user.confirmation_code).to be_nil
    end

    it 'возвращает false при неверном коде' do
      expect(user.verify('0000')).to be false
    end
  end
end

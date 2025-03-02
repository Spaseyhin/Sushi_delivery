# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Users' do
  let(:user) { create(:user) }

  describe 'POST /users' do
    it 'создаёт пользователя и отправляет код' do
      post users_path, params: { phone_number: '+79990001122' }, as: :turbo_stream
      expect(response).to have_http_status(:ok) # Проверяем, что запрос успешный
    end
  end

  describe 'POST /verify' do
    before { user.generate_confirmation_code! }

    it 'успешно верифицирует пользователя с правильным кодом' do
      post verify_user_path, params: { phone_number: user.phone_number, confirmation_code: user.confirmation_code },
                             as: :turbo_stream
      expect(response).to redirect_to(root_path) # Проверяем редирект
    end

    it 'отклоняет неверный код' do
      post verify_user_path, params: { phone_number: user.phone_number, confirmation_code: '0000' }, as: :turbo_stream
      expect(response.body).to include('Invalid code') # Проверяем, что отобразилось сообщение об ошибке
    end
  end

  describe 'DELETE /logout' do
    it 'разлогинивает пользователя' do # rubocop:disable RSpec/MultipleExpectations
      delete logout_path
      expect(session[:user_id]).to be_nil # Проверяем, что сессия очищена
      expect(response).to redirect_to(root_path) # Проверяем редирект
    end
  end
end

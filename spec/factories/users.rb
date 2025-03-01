# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    phone_number { 'MyString' }
    confirmation_code { 'MyString' }
    confirmation_code_sent_at { '2025-01-17 03:41:30' }
  end
end

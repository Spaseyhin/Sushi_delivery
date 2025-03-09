# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:phone_number) { |n| "+7111222334#{n}" } # Делаем уникальные номера
    confirmation_code { nil }
    confirmation_code_sent_at { nil }
  end
end

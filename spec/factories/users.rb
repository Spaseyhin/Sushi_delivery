# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:phone_number) { |n| "+79#{n.to_s.rjust(9, '0')}" }
    confirmation_code { nil }
    confirmation_code_sent_at { nil }
  end
end

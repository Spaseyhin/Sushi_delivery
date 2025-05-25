# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    user { nil }
    status { 'MyString' }
  end
end

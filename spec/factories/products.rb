# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    name { 'MyString' }
    price { '9.99' }
    description { 'MyText' }
    image_url { 'MyString' }
    weight { 1 }
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :product do
    name { 'Test Sushi' }
    description { 'Tasty roll' }
    price { 100 }

    after(:build) do |product|
      product.image.attach(
        io: Rails.root.join('spec/fixtures/files/test_image.jpg').open,
        filename: 'test_image.jpg',
        content_type: 'image/jpeg'
      )
    end
  end
end

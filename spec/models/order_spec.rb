# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to have_many(:order_items).dependent(:destroy) }

  describe '.create_from_cart!' do
    let(:user) { create(:user) }
    let(:product) { create(:product, price: 100) }
    let(:cart) { create(:cart) }

    context 'when cart is empty' do
      it 'raises ArgumentError' do
        expect do
          described_class.create_from_cart!(user, cart)
        end.to raise_error(ArgumentError, I18n.t('order.cart_empty'))
      end
    end

    context 'when cart has items' do
      before do
        create(:cart_item, cart: cart, product: product, quantity: 2)
      end

      it 'creates an order with correct total price' do
        order = described_class.create_from_cart!(user, cart)
        expect(order.total_price).to eq(200)
        expect(order.order_items.count).to eq(1)
        expect(order.order_items.first.product).to eq(product)
      end

      it 'clears the cart after creating order' do
        described_class.create_from_cart!(user, cart)
        expect(cart.cart_items.count).to eq(0)
      end
    end
  end
end

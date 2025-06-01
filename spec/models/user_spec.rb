# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  include ActiveSupport::Testing::TimeHelpers
  describe 'associations' do
    it { is_expected.to have_one(:cart).dependent(:destroy) }
    it { is_expected.to have_many(:orders).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_uniqueness_of(:phone_number).case_insensitive }
    it { is_expected.to allow_value('+71234567890').for(:phone_number) }
    it { is_expected.not_to allow_value('12345').for(:phone_number) }
    it { is_expected.to validate_length_of(:confirmation_code).is_equal_to(4).allow_nil }
  end

  describe '#phone_number_cannot_be_repeating_digits' do
    it 'adds error if phone number is repeating digits' do
      user = build(:user, phone_number: '+71111111111')
      user.valid?
      expect(user.errors[:phone_number]).to include('не может состоять из одинаковых цифр')
    end

    it 'does not add error for normal phone number' do
      user = build(:user, phone_number: '+71234567890')
      user.valid?
      expect(user.errors[:phone_number]).to be_empty
    end
  end

  describe '#generate_confirmation_code!' do
    it 'generates a 4-digit code and sets sent_at' do
      user = create(:user)
      freeze_time do
        user.generate_confirmation_code!
        expect(user.confirmation_code).to match(/\A\d{4}\z/)
        expect(user.confirmation_code_sent_at).to eq(Time.current)
      end
    end
  end

  describe '#valid_confirmation_code?' do
    let(:user) { create(:user, confirmation_code: '1234', confirmation_code_sent_at: Time.current) }

    it 'returns true for correct code within time' do
      expect(user.valid_confirmation_code?('1234')).to be true
    end

    it 'returns false for wrong code' do
      expect(user.valid_confirmation_code?('0000')).to be false
    end

    it 'returns false for expired code' do
      user.update!(confirmation_code_sent_at: 11.minutes.ago)
      expect(user.valid_confirmation_code?('1234')).to be false
    end
  end

  describe '#verify' do
    let(:user) { create(:user, confirmation_code: '1234', confirmation_code_sent_at: Time.current) }

    it 'returns true and clears code if valid' do
      expect(user.verify('1234')).to be true
      expect(user.reload.confirmation_code).to be_nil
    end

    it 'returns false if code invalid' do
      expect(user.verify('0000')).to be false
    end
  end

  describe '#log_in!' do
    let(:user) { create(:user) }

    context 'when session is empty (new user)' do
      let(:session) { {} }

      it 'sets session user_id and creates a new cart' do
        expect do
          user.log_in!(session)
        end.to change { session[:user_id] }.to(user.id)
                                           .and change { session[:cart_id] }.from(nil).to(be_present)
      end
    end

    context 'when session contains guest cart' do
      let(:guest_cart) { create(:cart) }
      let(:session) { { cart_id: guest_cart.id } }

      before do
        create(:cart_item, cart: guest_cart)
      end

      it 'absorbs guest cart into user cart and deletes it' do
        expect do
          user.log_in!(session)
        end.to change { Cart.exists?(guest_cart.id) }.from(true).to(false)
      end
    end
  end
end

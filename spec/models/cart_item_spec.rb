# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CartItem do
  it { is_expected.to belong_to(:cart) }
  it { is_expected.to belong_to(:product) }

  it { is_expected.to validate_numericality_of(:quantity).is_greater_than(0) }
end

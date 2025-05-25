# frozen_string_literal: true

# CartItem represents an item in a user's cart. It links a specific product to a cart.
#
# Associations:
# - belongs_to :cart: Associates the cart item with a specific cart.
# - belongs_to :product: Associates the cart item with a specific product.
class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  def adjust_quantity!(change)
    new_quantity = quantity + change.to_i
    new_quantity.positive? ? update!(quantity: new_quantity) : destroy!
  end
end

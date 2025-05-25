# frozen_string_literal: true

# OrderItem represents an item within an order, linking a specific product to the order.
#
# Associations:
# - belongs_to :order: Associates the order item with a specific order.
# - belongs_to :product: Associates the order item with a specific product.
class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
end

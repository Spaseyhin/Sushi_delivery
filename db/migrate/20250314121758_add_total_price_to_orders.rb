# frozen_string_literal: true

# AddTotalPriceToOrders migration is responsible for adding the 'total_price' column to the 'orders' table.
# This column will store the total price of an order, with a precision of 10 digits and a scale of 2 decimals.
class AddTotalPriceToOrders < ActiveRecord::Migration[7.0]
  def change
    # Adds the 'total_price' column to the 'orders' table
    # The column will be of type decimal with precision of 10 and scale of 2
    add_column :orders, :total_price, :decimal, precision: 10, scale: 2
  end
end

# frozen_string_literal: true

# AddOrderNumberToOrders migration adds the 'order_number' column to the 'orders' table.
# This column will store a unique order number for each order.
class AddOrderNumberToOrders < ActiveRecord::Migration[7.0]
  def change
    # Adds the 'order_number' column to the 'orders' table with the type 'integer'
    add_column :orders, :order_number, :integer
  end
end

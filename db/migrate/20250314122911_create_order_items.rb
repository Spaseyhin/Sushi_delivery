# frozen_string_literal: true

# CreateOrderItems migration is responsible for creating the 'order_items' table in the database.
# This table serves as the join table between orders and products, with additional information like quantity and price
#  for each item in the order.
class CreateOrderItems < ActiveRecord::Migration[7.0]
  def change
    # Creates the 'order_items' table with references to 'orders' and 'products',
    # and additional columns for quantity and price of each item.
    create_table :order_items do |t|
      # Reference to the 'orders' table, ensuring each order item is linked to a specific order
      t.references :order, null: false, foreign_key: true

      # Reference to the 'products' table, ensuring each order item is linked to a specific product
      t.references :product, null: false, foreign_key: true

      # Column to store the quantity of the product in the order
      t.integer :quantity

      # Column to store the price of the product at the time of the order
      t.decimal :price

      # Timestamps for when the order item is created and updated
      t.timestamps
    end
  end
end

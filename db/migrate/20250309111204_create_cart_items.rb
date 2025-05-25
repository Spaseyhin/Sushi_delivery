# frozen_string_literal: true

# CreateCartItems migration is responsible for creating the cart_items table in the database.
# It defines the relationships between carts and products, and includes a column for quantity to track how many items
# of each product are in the cart.
class CreateCartItems < ActiveRecord::Migration[7.0]
  def change
    # Creates the 'cart_items' table with references to the 'carts' and 'products' tables, and a quantity field
    create_table :cart_items do |t|
      # Reference to the 'carts' table, ensuring each cart item is linked to a specific cart
      t.references :cart, null: false, foreign_key: true

      # Reference to the 'products' table, ensuring each cart item is linked to a specific product
      t.references :product, null: false, foreign_key: true

      # Column for the quantity of the product in the cart
      t.integer :quantity

      t.timestamps
    end
  end
end

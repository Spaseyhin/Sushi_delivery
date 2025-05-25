# frozen_string_literal: true

# CreateCarts migration is responsible for creating the carts table in the database.
# It establishes a reference to the user who owns the cart and includes timestamp fields for tracking creation and
# updates.
class CreateCarts < ActiveRecord::Migration[7.0]
  def change
    # Creates the 'carts' table with a reference to the 'users' table and timestamps
    create_table :carts do |t|
      # Adds a foreign key reference to the 'users' table, ensuring each cart is associated with a user
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end

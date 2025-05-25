# frozen_string_literal: true

# CreateOrders migration is responsible for creating the orders table in the database.
# It establishes a reference to the user who placed the order and includes a status field to track the order's state.
class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    # Creates the 'orders' table with a reference to the 'users' table and a column for order status
    create_table :orders do |t|
      # Reference to the 'users' table, ensuring each order is linked to a specific user
      t.references :user, null: false, foreign_key: true

      # Column for the order's status (e.g., pending, completed, shipped, etc.)
      t.string :status

      t.timestamps
    end
  end
end

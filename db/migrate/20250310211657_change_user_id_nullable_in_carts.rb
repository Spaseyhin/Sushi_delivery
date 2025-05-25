# frozen_string_literal: true

# ChangeUserIdNullableInCarts migration modifies the 'carts' table to allow the 'user_id' column to be nullable.
# This allows carts to exist without being associated with a user.
class ChangeUserIdNullableInCarts < ActiveRecord::Migration[7.0]
  def change
    # Alters the 'user_id' column in the 'carts' table to allow NULL values
    change_column_null :carts, :user_id, true
  end
end

# frozen_string_literal: true

# Adds an `address` column to the `users` table.
#
# This migration is used to store the user's address.
class AddAddressToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :address, :string
  end
end

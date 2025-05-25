# frozen_string_literal: true

# CreateProducts migration is responsible for creating the products table in the database.
# It defines the columns for the product name, price, description, image URL, and weight,
# as well as timestamp fields for tracking creation and updates.
class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    # Creates the 'products' table with specified columns for product details
    create_table :products do |t|
      # Column for the product name
      t.string :name

      # Column for the product price
      t.decimal :price

      # Column for the product description
      t.text :description

      # Column for the product image URL
      t.string :image_url

      # Column for the product weight
      t.integer :weight

      t.timestamps
    end
  end
end

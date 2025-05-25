# frozen_string_literal: true

# Cart model represents a user's shopping cart in the system.
# It manages the items (products) in the cart and their association with the user.
#
# Associations:
# - belongs_to :user (optional): Associates the cart with a user. This is optional, meaning a cart can exist without
#  being linked to a user.
# - has_many :cart_items, dependent: :destroy: A cart has many cart items. If the cart is destroyed, all associated cart
# items will also be destroyed.
# - has_many :products, through: :cart_items: A cart has many products through the cart_items association, enabling
# many-to-many relationships between carts and products.
class Cart < ApplicationRecord
  belongs_to :user, optional: true
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  # Adds a product to the cart. If the product already exists in the cart, it updates the quantity.
  def total_quantity
    cart_items.sum(:quantity)
  end

  def items
    cart_items.includes(product: [image_attachment: :blob]).joins(:product).order('products.name ASC')
  end

  # Calculates the total price of all items in the cart.
  def total_price
    cart_items.sum { |item| item.product.price * item.quantity }
  end

  def clear_items
    cart_items.destroy_all
  end

  def items_hash
    cart_items.each_with_object({}) { |item, hash| hash[item.product_id] = item.quantity }
  end

  def absorb_from(guest_cart)
    guest_cart.cart_items.each do |item|
      existing_item = cart_items.find_by(product_id: item.product_id)

      if existing_item
        existing_item.update(quantity: existing_item.quantity + item.quantity)
      else
        cart_items.create(product_id: item.product_id, quantity: item.quantity)
      end
    end
  end

  def self.for(user:, session:)
    if user
      user.cart || user.create_cart
    elsif session[:cart_id]
      cart = Cart.find_by(id: session[:cart_id])
      return cart if cart

      session[:cart_id] = nil
      create_guest_cart(session)
    else
      create_guest_cart(session)
    end
  end

  def add_product(product)
    cart_item = cart_items.find_or_initialize_by(product: product)
    cart_item.quantity ||= 0
    cart_item.quantity += 1
    cart_item.save!
  end

  def self.create_guest_cart(session)
    Cart.create.tap do |cart|
      session[:cart_id] = cart.id if cart.persisted?
    end
  end
end

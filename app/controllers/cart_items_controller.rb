# frozen_string_literal: true

# CartItemsController handles the creation, updating, and deletion of cart items in the shopping cart.
#
# This controller allows users to add, update, and remove items from their shopping cart.
# It responds to Turbo Streams for real-time updates to the cart's contents.
class CartItemsController < ApplicationController
  # Creates a new cart item or increments the quantity of an existing item in the cart.
  #
  # @return [void]
  def create
    product = Product.find(params[:product_id])
    current_cart.add_product(product)
    load_cart_items

    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_cart_update(product) }
      format.html { redirect_to root_path }
    end
  end

  # Updates the quantity of an existing cart item, or removes it if the quantity is 0 or less.
  #
  # @return [void]
  def update
    cart_item = current_cart.cart_items.find(params[:id])
    cart_item.adjust_quantity!(params[:change])
    load_cart_items
    respond_with_cart_update(cart_item.product)
  end

  # Removes a cart item from the cart.
  #
  # @return [void]
  def destroy
    cart_item = current_cart.cart_items.find(params[:id])
    cart_item.destroy

    load_cart_items
    respond_with_cart_update(cart_item.product)
  end

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    redirect_to root_path
  end

  def respond_with_cart_update(product)
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_cart_update(product) }
      format.html { redirect_to root_path }
    end
  end

  def turbo_cart_update(product)
    [
      turbo_cart_frame,
      turbo_cart_count,
      turbo_product_replace(product)
    ]
  end

  def turbo_cart_frame
    turbo_stream.update(
      'cart-frame',
      partial: 'carts/cart_items',
      locals: {
        cart_items: @cart_items,
        cart_total_price: @cart_total_price
      }
    )
  end

  def turbo_cart_count
    turbo_stream.update('cart-count', @cart_items_count)
  end

  def turbo_product_replace(product)
    cart_item = @cart_items.find { |item| item.product_id == product.id }

    turbo_stream.replace(
      "product-#{product.id}",
      partial: 'products/product',
      locals: {
        product: product,
        quantity: @cart_items_hash[product.id] || 0,
        cart_item: cart_item
      }
    )
  end
end

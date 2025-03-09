class CartItemsController < ApplicationController
  def create
    cart = current_cart
    product = Product.find(params[:product_id])

    cart_item = cart.cart_items.find_by(product: product)

    if cart_item
      cart_item.increment!(:quantity)
    else
      cart.cart_items.create(product: product, quantity: 1)
    end

    redirect_to cart_path, notice: 'Товар добавлен в корзину!'
  end

  def update
  end

  def destroy
  end

  private

  def current_cart
    @current_cart ||= Cart.find_or_create_by(user: current_user)
  end
end

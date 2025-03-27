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

    load_cart_items # обновить данные после изменения

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          #  Обновить корзину (модалку)
          turbo_stream.update('cart-frame', partial: 'carts/cart_items',
                                            locals: { cart_items: @cart_items, cart_total_price: @cart_total_price }),
          #  Обновить счетчик корзины
          turbo_stream.update('cart-count', @cart_items_count),
          #  Обновить карточку именно этого товара
          turbo_stream.replace("product-#{product.id}", partial: 'products/product',
                                                        locals: { product: product, quantity: @cart_items_hash[product.id] || 0 })
        ]
      end
      format.html { redirect_to root_path, notice: 'Товар добавлен в корзину' }
    end
  end

  def update
    cart_item = current_cart.cart_items.find(params[:id])
    new_quantity = cart_item.quantity + params[:change].to_i

    if new_quantity > 0
      cart_item.update(quantity: new_quantity)
    else
      cart_item.destroy
    end

    load_cart_items

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: [
          #  Обновить корзину (модалку)
          turbo_stream.update('cart-frame', partial: 'carts/cart_items',
                                            locals: { cart_items: @cart_items, cart_total_price: @cart_total_price }),
          #  Обновить счетчик корзины
          turbo_stream.update('cart-count', @cart_items_count),
          #  Обновить карточку товара
          turbo_stream.replace("product-#{cart_item.product.id}", partial: 'products/product',
                                                                  locals: { product: cart_item.product,
                                                                            quantity: @cart_items_hash[cart_item.product.id] || 0 })
        ]
      end
      format.html { redirect_to root_path, notice: 'Корзина обновлена' }
    end
  end

  def destroy
    cart_item = current_cart.cart_items.find(params[:id])
    cart_item.destroy

    load_cart_items

    respond_to do |format|
      format.turbo_stream
    end
  end
end

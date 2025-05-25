# frozen_string_literal: true

# ProductsController is responsible for managing the products in the application.
# It handles the display of products in the store, including showing a list of all products
# and displaying individual product details.
#
# Actions:
# - `index`: Displays a list of all products.
# - `show`: Displays the details of a specific product.
#
# @see Product
class ProductsController < ApplicationController
  # Displays a list of all products available in the store.
  #
  # This action fetches all products from the database and loads them to be displayed to the user.
  # It also loads the cart items to display them in the cart.
  #
  # @return [Array<Product>] list of all products
  def index
    @products = Product.active
                       .includes(image_attachment: :blob)
                       .order(created_at: :asc, name: :asc) # исключаем удалённые
    load_cart_items
  end

  # Displays the details of a specific product.
  #
  # This action finds a single product based on the provided ID in the parameters.
  #
  # @param id [Integer] the ID of the product to be displayed
  # @return [Product] the product details
  def show
    @product = Product.find(params[:id])
  end

  private

  # Strong parameters for product attributes.
  # Only allows the specified attributes to be passed in for a product.
  #
  # @return [ActionController::Parameters] the permitted product parameters
  def product_params
    params.require(:product).permit(:name, :price, :description, :weight, :image)
  end
end

class ProductsController < ApplicationController
  def index
    @products = Product.all
    load_cart_items
  end

  def show
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :price, :description, :weight, :image)
  end
end

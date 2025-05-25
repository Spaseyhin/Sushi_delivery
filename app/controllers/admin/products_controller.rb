# frozen_string_literal: true

module Admin
  # Admin::ProductsController is responsible for managing the products in the admin panel.
  # This controller allows the admin user to perform CRUD (Create, Read, Update, Delete) operations
  # on the products available in the application.
  #
  # Actions:
  # - `index`: Displays a list of all products.
  # - `new`: Renders the form for creating a new product.
  # - `edit`: Renders the form for editing an existing product.
  # - `create`: Creates a new product.
  # - `update`: Updates an existing product.
  # - `destroy`: Deletes a product.
  #
  # @see Product
  class ProductsController < ApplicationController
    # Before actions
    before_action :authenticate_admin_user!
    before_action :set_product, only: %i[edit update destroy]
    layout 'admin'

    # GET /admin/products
    #
    # This action fetches and displays all the products in the admin panel.
    #
    # @return [Array<Product>] list of all products
    def index
      @products = Product.active.order(created_at: :asc, name: :asc) # Старые сверху, затем сортировка по имени
    end

    # GET /admin/products/new
    #
    # This action renders the form for creating a new product.
    #
    # @return [Product] the newly created product
    def new
      @product = Product.new
    end

    # GET /admin/products/:id/edit
    #
    # This action renders the form for editing an existing product.
    #
    # @param id [Integer] the ID of the product to be edited
    # @return [Product] the product to be edited
    def edit; end

    # POST /admin/products
    #
    # This action creates a new product based on the submitted form data.
    # If the product is saved successfully, it redirects to the product list page,
    # otherwise, it re-renders the new product form.
    #
    # @return [redirect] redirects to the admin products page if successful, renders new form if failed
    def create
      @product = Product.new(product_params)
      if @product.save
        redirect_to admin_products_path
      else
        render :new
      end
    end

    # PATCH/PUT /admin/products/:id
    #
    # This action updates an existing product with the submitted form data.
    # If the update is successful, it redirects to the product list page,
    # otherwise, it re-renders the edit product form.
    #
    # @param id [Integer] the ID of the product to be updated
    # @return [redirect] redirects to the admin products page if successful, renders edit form if failed
    def update
      if @product.update(product_params)
        redirect_to admin_products_path
      else
        render :edit
      end
    end

    # DELETE /admin/products/:id
    #
    # This action deletes a product from the database.
    # After deletion, it redirects to the admin products page.
    #
    # @param id [Integer] the ID of the product to be deleted
    # @return [redirect] redirects to the admin products page after deletion
    def destroy
      @product.soft_delete
      redirect_to admin_products_path
    end

    private

    # Finds the product based on the given id from the params.
    #
    # @return [Product] the product to be used in edit, update, or destroy actions
    def set_product
      @product = Product.find(params[:id])
    end

    # Strong parameters to allow only permitted product attributes.
    #
    # @return [ActionController::Parameters] the permitted product parameters
    def product_params
      params.require(:product).permit(:name, :description, :price, :image)
    end
  end
end

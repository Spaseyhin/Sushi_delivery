# frozen_string_literal: true

module Admin
  # Admin::OrdersController is responsible for managing the orders within the admin section of the application.
  # It handles displaying the list of orders to the admin user and ensuring authentication before access.
  #
  # Callbacks:
  # - before_action :authenticate_admin_user!: Ensures that an admin user is authenticated before any
  #  action is performed in this controller.
  #
  # Actions:
  # - index: Retrieves and displays a list of orders, ordered by their creation date in descending order.
  class OrdersController < ApplicationController
    before_action :authenticate_admin_user!
    layout 'admin'

    # Displays all orders sorted by creation date in descending order.
    def index
      @orders = Order.order(created_at: :desc)
    end
  end
end

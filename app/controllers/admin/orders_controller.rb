# frozen_string_literal: true

class Admin::OrdersController < ApplicationController
  before_action :authenticate_admin_user!
  layout 'admin'

  def index
    @orders = Order.order(created_at: :desc)
  end
end

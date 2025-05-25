# frozen_string_literal: true

module Admin
  # HomeController is the main controller for the admin section of the application.
  class HomeController < ApplicationController
    def index
      if admin_user_signed_in?
        redirect_to admin_products_path
      else
        redirect_to new_admin_user_session_path
      end
    end
  end
end

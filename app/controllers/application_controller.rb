# frozen_string_literal: true

# Base application controller that provides user authentication helpers.
class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  # Returns the currently logged-in user, if any.
  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  # Returns true if a user is logged in, false otherwise.
  def logged_in?
    current_user.present?
  end
end

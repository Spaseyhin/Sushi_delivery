# frozen_string_literal: true

# AdminUser represents an admin user in the application.
# It is responsible for handling authentication, registration, and user session management.
# The class inherits from ApplicationRecord and uses Devise for user authentication.
#
# Devise modules included:
# - :database_authenticatable: Allows users to sign in using an encrypted password.
# - :registerable: Handles user sign-up and registration.
# - :recoverable: Allows password recovery (resetting forgotten passwords).
# - :rememberable: Manages the "remember me" functionality to keep users signed in.
# - :validatable: Validates email and password.
class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end

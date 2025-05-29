# frozen_string_literal: true

class AddDefaultAdminUser < ActiveRecord::Migration[7.0]
  def up
    AdminUser.find_or_create_by!(email: 'admin@example.com') do |admin|
      admin.password = 'password'
      admin.password_confirmation = 'password'
    end
  end

  def down
    AdminUser.find_by(email: 'admin@example.com')&.destroy
  end
end

# frozen_string_literal: true

# DeviseCreateAdminUsers migration is responsible for creating the 'admin_users' table.
# This table is used to store admin users' authentication data, such as email and encrypted password,
# as well as various Devise features like password recovery, rememberable, and others.
class DeviseCreateAdminUsers < ActiveRecord::Migration[7.0]
  def change
    # Creates the 'admin_users' table with columns required by Devise for authentication
    create_table :admin_users do |t|
      ## Database authenticatable
      # Email for the admin user, cannot be null, default is an empty string
      t.string :email,              null: false, default: ''
      # Encrypted password for the admin user, cannot be null, default is an empty string
      t.string :encrypted_password, null: false, default: ''

      ## Recoverable
      # Token for resetting the password
      t.string   :reset_password_token
      # Date and time when the reset password token was sent
      t.datetime :reset_password_sent_at

      ## Rememberable
      # Date and time when the admin user was remembered
      t.datetime :remember_created_at

      ## Trackable (commented out, not being used currently)
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      ## Confirmable (commented out, not being used currently)
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable (commented out, not being used currently)
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      # Timestamps for when the record is created and updated
      t.timestamps null: false
    end

    # Adds unique indexes for email and reset password token for performance and uniqueness checks
    add_index :admin_users, :email,                unique: true
    add_index :admin_users, :reset_password_token, unique: true
    # add_index :admin_users, :confirmation_token,   unique: true
    # add_index :admin_users, :unlock_token,         unique: true
  end
end

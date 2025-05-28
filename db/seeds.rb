# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# Удаление дублирующихся значений в поле order_number
Order.group(:order_number).having('COUNT(*) > 1').pluck(:order_number).each do |duplicate_order_number|
  orders = Order.where(order_number: duplicate_order_number).order(:id)
  orders.offset(1).each_with_index do |order, index|
    order.update!(order_number: duplicate_order_number.to_i + index + 1)
  end
end

AdminUser.find_or_create_by!(email: 'admin@example.com') do |admin|
  admin.password = 'password'
  admin.password_confirmation = 'password'
end

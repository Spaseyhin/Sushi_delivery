class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  after_create_commit lambda {
    broadcast_prepend_later_to 'orders',
                               target: 'orders',
                               partial: 'admin/orders/order',
                               locals: { order: self }
  }
end

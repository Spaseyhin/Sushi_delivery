# frozen_string_literal: true

# Product represents an item that can be sold in the system.
# It may have an image attached to it.
#
# Associations:
# - has_one_attached :image: Allows a product to have a single image attached using ActiveStorage.
class Product < ApplicationRecord
  has_one_attached :image

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :description, presence: true
  validate :image_presence

  scope :active, -> { where(deleted_at: nil) }
  scope :deleted, -> { where.not(deleted_at: nil) }

  def soft_delete
    update(deleted_at: Time.current)
  end

  def deleted?
    deleted_at.present?
  end

  private

  def image_presence
    errors.add(:image, 'должно быть загружено') unless image.attached?
  end
end

# frozen_string_literal: true

# Contains all items for a guild
class Inventory < ApplicationRecord
  belongs_to :storable, polymorphic: true
  has_many :items, dependent: :destroy

  validates :storable_id, uniqueness: { scope: :storable_type, message: I18n.t('errors.inventories.uniqueness') }
end

# frozen_string_literal: true

# Contains all items for a guild
class Inventory < ApplicationRecord
  belongs_to :guild
  has_many :items, dependent: :destroy

  validates :guild_id, presence: true
  validates_uniqueness_of :guild_id, message: I18n.t('errors.inventories.uniqueness')
end

# frozen_string_literal: true

# A record of commodity acquisition
class Item < ApplicationRecord
  belongs_to :inventory
  belongs_to :commodity

  validates :inventory, presence: true
  validates :commodity, presence: true
end

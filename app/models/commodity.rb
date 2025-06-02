# frozen_string_literal: true

# Represents some kind of tangible good, such as a reagent for a potion
class Commodity < ApplicationRecord
  enum :category, { untyped: 0, materials: 1, provisions: 2, equipment: 3, consumables: 4, literature: 5 }
  enum :rarity, { common: 0, uncommon: 1, scarce: 2, rare: 3, extraordinary: 4, mythic: 5 }

  # Define the list of valid commodity types
  COMMODITY_TYPES = [
    'Mineral',
    'Metal',
    'Herb',
    'Plant',
    'Food',
    'Tool',
    'Weapon',
    'Armor',
    'Potion',
    'Scroll',
    'Book',
    'Gemstone',
    'Cloth',
    'Leather',
    'Jewelry',
    'Magical Artifact',
    'Furnishing',
    'Crafting Material',
    'Animal',
    'Mount',
    'Beverage',
    'Trophy',
    'Relic',
    'Seed',
    'Spice',
    'Crafted Good'
  ].freeze

  has_many :items, dependent: :destroy
  has_many :supplier_goods, dependent: :destroy

  validates :name, uniqueness: true, presence: true
  validates :description, presence: true
  validates :value, numericality: { greater_than_or_equal_to: 0 }
  validates :commodity_type, presence: true, inclusion: { in: COMMODITY_TYPES }
  validates :unit, presence: true
end

# frozen_string_literal: true

# Represents some kind of tangible good, such as a reagent for a potion
class Commodity < ApplicationRecord
  enum :category, { untyped: 0, materials: 1, provisions: 2, equipment: 3, consumables: 4, literature: 5 }

  has_many :items, dependent: :destroy

  validates :name, uniqueness: true, presence: true
  validates :description, presence: true
  validates :value, comparison: { greater_than_or_equal_to: 0 }
  validates :commodity_type, presence: true
  validates :origin, presence: true
  validates :unit, presence: true
end

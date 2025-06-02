# frozen_string_literal: true

# Generates the commodities that feed all other entities at set intervals
class Supplier < ApplicationRecord
  has_many :supplier_goods, dependent: :destroy
end

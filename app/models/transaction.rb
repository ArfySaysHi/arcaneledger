# frozen_string_literal: true

# Holds the description of a transaction alongside timing info
class Transaction < ApplicationRecord
  validates :transaction_date, presence: true
end

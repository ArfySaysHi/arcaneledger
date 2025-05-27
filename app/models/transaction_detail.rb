# frozen_string_literal: true

# Holds the description of a transaction alongside timing info
class TransactionDetail < ApplicationRecord
  has_many :journal_entries, dependent: :destroy
  has_many :ledgers, dependent: :destroy

  validates :transaction_date, presence: true
end

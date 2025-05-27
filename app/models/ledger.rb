# frozen_string_literal: true

# Contains categorized financial details to go alongside the journal entries
class Ledger < ApplicationRecord
  enum :entry_type, { debit: 0, credit: 1 }

  belongs_to :account
  belongs_to :transaction_detail

  validates :amount, presence: true, numericality: { only_integer: true }
  validates :entry_type, presence: true, inclusion: { in: %w[0 1 debit credit] }
end

# frozen_string_literal: true

# Holds the monetary effect of a transaction on an account
class JournalEntry < ApplicationRecord
  belongs_to :transaction_detail
  belongs_to :account
end

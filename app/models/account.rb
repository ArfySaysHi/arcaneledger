# frozen_string_literal: true

# Contains a list of debits and credits with context
class Account < ApplicationRecord
  enum :account_type, { asset: 0, liability: 1, equity: 2, revenue: 3, expense: 4 }

  belongs_to :guild
  has_many :journal_entries, dependent: :destroy
  has_many :ledgers, dependent: :destroy

  validates :name, presence: true
  validates :account_type, presence: true
  validates :balance, numericality: { only_integer: true }
end

# frozen_string_literal: true

require 'test_helper'

class LedgerTest < ActiveSupport::TestCase
  class LedgerValidation < LedgerTest
    test 'should check for account presence' do
      ledger = Ledger.create(account_id: nil, transaction_detail_id: transaction_details(:one).id, amount: 100,
                             entry_type: 'debit')

      assert_not ledger.valid?
      assert_not ledger.persisted?
      assert_equal 'Account must exist', ledger.errors.full_messages[0]
    end

    test 'should check for transaction presence' do
      ledger = Ledger.create(account_id: accounts(:one).id, transaction_detail_id: nil, amount: 100,
                             entry_type: 'debit')

      assert_not ledger.valid?
      assert_not ledger.persisted?
      assert_equal 'Transaction detail must exist', ledger.errors.full_messages[0]
    end

    test 'should check for amount presence' do
      ledger = Ledger.create(account_id: accounts(:one).id, transaction_detail_id: transaction_details(:one).id,
                             amount: nil, entry_type: 'debit')

      assert_not ledger.valid?
      assert_not ledger.persisted?
      assert_equal "Amount can't be blank", ledger.errors.full_messages[0]
    end

    test 'should check for entry_type presence' do
      ledger = Ledger.create(account_id: accounts(:one).id, transaction_detail_id: transaction_details(:one).id,
                             amount: 100, entry_type: nil)

      assert_not ledger.valid?
      assert_not ledger.persisted?
      assert_equal "Entry type can't be blank", ledger.errors.full_messages[0]
    end

    test 'should check for entry_type content' do
      assert_raises(ArgumentError, "'cwedit' is not a valid entry_type") do
        Ledger.create(account_id: accounts(:one).id, transaction_detail_id: transaction_details(:one).id,
                      amount: 100, entry_type: 'cwedit')
      end
    end
  end
end

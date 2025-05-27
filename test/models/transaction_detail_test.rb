# frozen_string_literal: true

require 'test_helper'

class TransactionDetailTest < ActiveSupport::TestCase
  class TransactionDetailValidations < TransactionDetailTest
    test 'should check for the presence of a date' do
      tra = TransactionDetail.create(description: 'description')

      assert_not tra.valid?
      assert_not tra.persisted?
      assert_equal "Transaction date can't be blank", tra.errors.full_messages[0]
    end

    test 'should create a valid transaction' do
      tra = TransactionDetail.create(transaction_date: Date.new(2025, 1, 1), description: 'words')

      assert tra.valid?
      assert tra.persisted?
    end
  end
end

# frozen_string_literal: true

require 'test_helper'

class JournalEntryTest < ActiveSupport::TestCase
  # TODO: Write tests covering the cascade functionality in relation to accounts and transaction_details
  class JournalEntryValidations < JournalEntryTest
    test 'should validates the presence of transaction_id' do
      je = JournalEntry.create(account_id: accounts(:one).id)

      assert_not je.valid?
      assert_not je.persisted?
      assert_equal 'Transaction detail must exist', je.errors.full_messages[0]
    end
  end
end

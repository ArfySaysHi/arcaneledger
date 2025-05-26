# frozen_string_literal: true

require 'test_helper'

class AccountTest < ActiveSupport::TestCase
  class AccountValidation < AccountTest
    test 'should check for the presence of account_name' do
      acc = Account.new(name: nil, account_type: 0, guild_id: guilds(:one).id)
      acc.save

      assert_not acc.valid?
      assert_not acc.persisted?
      assert_equal "Name can't be blank", acc.errors.full_messages[0]
    end

    test 'should check for the presence of account_type' do
      acc = Account.new(name: 'account name', account_type: nil, guild_id: guilds(:one).id)
      acc.save

      assert_not acc.valid?
      assert_not acc.persisted?
      assert_equal "Account type can't be blank", acc.errors.full_messages[0]
    end

    test 'should check for numericality of balance' do
      acc = Account.new(name: 'account name', account_type: 0, balance: 'notanumber', guild_id: guilds(:one).id)
      acc.save

      assert_not acc.valid?
      assert_not acc.persisted?
      assert_equal 'Balance is not a number', acc.errors.full_messages[0]
    end

    test 'should check for a guild' do
      acc = Account.new(name: 'account name', account_type: 0, balance: 'notanumber')
      acc.save

      assert_not acc.valid?
      assert_not acc.persisted?
      assert_equal 'Guild must exist', acc.errors.full_messages[0]
    end

    test 'should be able to create a valid account' do
      acc = Account.create(name: 'assets', account_type: 0, guild_id: guilds(:one).id)

      assert acc.valid?
      assert acc.persisted?
    end
  end
end

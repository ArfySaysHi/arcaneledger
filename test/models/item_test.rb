# frozen_string_literal: true

require 'test_helper'

class ItemTest < ActiveSupport::TestCase
  class ItemValidations < ItemTest
    test 'should require an inventory' do
      item = Item.create(amount: 1, price_on_acquisition: 2, commodity_id: commodities(:wheat).id, inventory_id: nil)

      assert_not item.valid?
      assert_not item.persisted?
      assert_equal 'Inventory must exist', item.errors.full_messages[0]
    end

    test 'should require a commodity' do
      item = Item.create(amount: 1, price_on_acquisition: 2, commodity_id: nil, inventory_id: inventories(:one).id)

      assert_not item.valid?
      assert_not item.persisted?
      assert_equal 'Commodity must exist', item.errors.full_messages[0]
    end
  end

  class ItemAssociations < ItemTest
    test 'should destroy self if inventory is destroyed' do
      item = Item.create(amount: 1, price_on_acquisition: 2, commodity_id: commodities(:wheat).id,
                         inventory_id: inventories(:one).id)

      assert item.persisted?
      inventories(:one).destroy
      assert_raises(ActiveRecord::RecordNotFound) do
        Item.find(item.id)
      end
    end

    test 'should destroy self if commodity is destroyed' do
      item = Item.create(amount: 1, price_on_acquisition: 2, commodity_id: commodities(:wheat).id,
                         inventory_id: inventories(:one).id)

      assert item.persisted?
      commodities(:wheat).destroy
      assert_raises(ActiveRecord::RecordNotFound) do
        Item.find(item.id)
      end
    end
  end
end

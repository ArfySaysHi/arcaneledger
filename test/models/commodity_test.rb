# frozen_string_literal: true

require 'test_helper'

class CommodityTest < ActiveSupport::TestCase
  class CommodityValidations < CommodityTest
    test 'should ensure the name is unique' do
      com = Commodity.create(**commodities(:wheat).attributes)

      assert_not com.valid?
      assert_equal 'Name has already been taken', com.errors.full_messages[0]
    end

    test 'should ensure the name is present' do
      com = Commodity.create(**commodities(:wheat).attributes, name: nil)

      assert_not com.valid?
      assert_equal "Name can't be blank", com.errors.full_messages[0]
    end

    test 'should ensure the description is present' do
      com = Commodity.create(**commodities(:wheat).attributes, name: 'Not Wheat', description: nil)

      assert_not com.valid?
      assert_equal "Description can't be blank", com.errors.full_messages[0]
    end

    test 'should ensure the value is greater than 0' do
      com = Commodity.create(**commodities(:wheat).attributes, name: 'Not Wheat', value: -1)

      assert_not com.valid?
      assert_equal 'Value must be greater than or equal to 0', com.errors.full_messages[0]
    end

    test 'should be fine with a value of 0' do
      com = Commodity.create(**commodities(:wheat).attributes, id: 999, name: 'Not Wheat', value: 0)

      assert com.valid?
    end

    test 'should ensure the commodity_type is present' do
      com = Commodity.create(**commodities(:wheat).attributes, id: 999, name: 'Not Wheat', commodity_type: nil)

      assert_not com.valid?
      assert_equal "Commodity type can't be blank", com.errors.full_messages[0]
    end

    test 'should ensure the unit is present' do
      com = Commodity.create(**commodities(:wheat).attributes, id: 999, name: 'Not Wheat', unit: nil)

      assert_not com.valid?
      assert_equal "Unit can't be blank", com.errors.full_messages[0]
    end

    test 'should ensure the commodity_type is valid' do
      com = Commodity.create(**commodities(:wheat).attributes, id: 999, name: 'Not Wheat', commodity_type: 'Not Real')

      assert_not com.valid?
      assert_equal "Commodity type is not included in the list", com.errors.full_messages[0]
    end
  end
end

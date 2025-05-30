# frozen_string_literal: true

require 'test_helper'

class InventoryTest < ActiveSupport::TestCase
  test 'should return an error if guild_id is blank' do
    inv = Inventory.create

    assert_not inv.valid?
    assert_equal 'Storable must exist', inv.errors.full_messages[0]
  end

  test 'should return an error if the guild already has an inventory' do
    inv = Inventory.create(storable_id: guilds(:one).id, storable_type: 'Guild')

    assert_not inv.valid?
    assert_equal 'Storable supplied already has an inventory.', inv.errors.full_messages[0]
  end

  test 'should create an inventory when a valid guild is created' do
    guild = Guild.create(name: 'valid', motto: 'guild')

    assert guild.inventory
  end

  test 'should destroy the inventory alongside the guild' do
    guild = Guild.create(name: 'cool', motto: 'guys')
    inv = guild.inventory

    assert inv.persisted?
    guild.destroy!
    assert_not inv.persisted?
  end
end

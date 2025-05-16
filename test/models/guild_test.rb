# frozen_string_literal: true

require 'test_helper'

class GuildTest < ActiveSupport::TestCase
  class GuildValidation < GuildTest
    test 'should reject a duplicate guild name' do
      Guild.create!(name: 'dupe', motto: 'motto')

      assert_raises(ActiveRecord::RecordInvalid, match: /Name has already been taken/i) do
        Guild.create!(name: 'dupe', motto: 'mottoagain')
      end
    end

    test 'should reject a guild with an empty name' do
      guild = Guild.new(motto: 'motto')

      assert_not guild.valid?
      assert_includes guild.errors.full_messages, "Name can't be blank"
    end

    test 'should reject a guild with an empty motto' do
      guild = Guild.new(name: 'guildname', motto: nil)

      assert_not guild.valid?
      assert_includes guild.errors.full_messages, "Motto can't be blank"
    end
  end
end

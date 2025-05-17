# frozen_string_literal: true

require 'test_helper'

class GuildsControllerTest < ActionDispatch::IntegrationTest
  class GuildsCreate < GuildsControllerTest
    test 'should fail if the user is not logged in' do
      post guilds_url, params: { guild: { name: 'newguild', motto: 'motto' } }

      assert_equal 403, @response.status
      assert_equal I18n.t('auth.auth_fail'), @response.parsed_body[:errors][0]
    end

    test 'should fail if user is already part of a guild' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      post guilds_url, params: { guild: { name: 'newguild', motto: 'motto' } }

      assert_equal 422, @response.status
      assert_equal I18n.t('guilds.already_in_a_guild'), @response.parsed_body[:errors][0]
    end

    test 'should fail if the guild is missing a name' do
      post login_url, params: { user: { email: users(:guildless).email, password: 'password' } }
      post guilds_url, params: { guild: { name: nil, motto: 'motto' } }

      assert_equal 422, @response.status
      assert_equal "Name can't be blank", @response.parsed_body[:errors][0]
    end

    test 'should fail if the guild is missing a motto' do
      post login_url, params: { user: { email: users(:guildless).email, password: 'password' } }
      post guilds_url, params: { guild: { name: 'newguild', motto: nil } }

      assert_equal 422, @response.status
      assert_equal "Motto can't be blank", @response.parsed_body[:errors][0]
    end

    test 'should succeed if valid params given by a guildless user' do
      post login_url, params: { user: { email: users(:guildless).email, password: 'password' } }
      post guilds_url, params: { guild: { name: 'newguild', motto: 'motto' } }

      assert_equal 201, @response.status
      assert_equal I18n.t('guilds.create_success'), @response.parsed_body[:message]
    end
  end

  class GuildsDestroy < GuildsControllerTest
    test 'should fail if the user is unauthenticated' do
      delete guild_url

      assert_equal 403, @response.status
      assert_equal I18n.t('auth.auth_fail'), @response.parsed_body[:errors][0]
    end

    test 'should fail if the user is not linked to a guild' do
      post login_url, params: { user: { email: users(:guildless).email, password: 'password' } }
      delete guild_url

      assert_equal 404, @response.status
      assert_equal I18n.t('guilds.does_not_exist'), @response.parsed_body[:errors][0]
    end

    test 'should destroy the users guild if authed' do
      post login_url, params: { user: { email: users(:guild_member).email, password: 'password' } }
      delete guild_url

      assert_equal 200, @response.status
      assert_equal I18n.t('guilds.destroy_success'), @response.parsed_body[:message]

      get user_url(users(:guild_member).id)

      # All guild members will have their guild nullified
      assert_equal 403, @response.status
      assert_equal I18n.t('guilds.must_be_in_a_guild'), @response.parsed_body[:errors][0]
    end
  end
end

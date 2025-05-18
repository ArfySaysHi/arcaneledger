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

  class GuildInviteMember < GuildsControllerTest
    test 'should fail if the user is not logged in' do
      post invite_member_guilds_url, params: { user: { email: users(:guildless) } }

      assert_equal 403, @response.status
      assert_equal I18n.t('auth.auth_fail'), @response.parsed_body[:errors][0]
    end

    test 'should fail if the user is not linked to a guild' do
      post login_url, params: { user: { email: users(:guildless).email, password: 'password' } }
      delete guild_url

      assert_equal 404, @response.status
      assert_equal I18n.t('guilds.does_not_exist'), @response.parsed_body[:errors][0]
    end

    test 'should fail if the user is not found' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      post invite_member_guilds_url, params: { user: { email: 'scoob@scoob.com' } }

      assert_equal 404, @response.status
      assert_equal I18n.t('general.not_found'), @response.parsed_body[:errors][0]
    end

    test 'should fail if the invited user is in a guild' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      post invite_member_guilds_url, params: { user: { email: users(:guild_member).email } }

      assert_equal 404, @response.status
      assert_equal I18n.t('general.not_found'), @response.parsed_body[:errors][0]
    end

    test 'should send an email if all params are valid' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      post invite_member_guilds_url, params: { user: { email: users(:guildless).email } }

      assert_equal 201, @response.status
      assert_equal I18n.t('guilds.invite_member_success'), @response.parsed_body[:message]
      assert_equal I18n.t('guilds.subject_invite'), ActionMailer::Base.deliveries.last.subject
    end
  end

  class GuildsAcceptInvitation < GuildsControllerTest
    test 'should fail if the invitation token is invalid or missing' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      get accept_invitation_guilds_url

      assert_equal 404, @response.status
      assert_equal I18n.t('general.not_found'), @response.parsed_body[:errors][0]
    end

    test 'should fail if the user token is invalid or missing' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      post invite_member_guilds_url, params: { user: { email: users(:guildless).email } }

      url = retrieve_join_url
      invitation_token = CGI.parse(URI.parse(url).query)['invitation_token'][0]
      get accept_invitation_guilds_url, params: { invitation_token: invitation_token }

      assert_equal 404, @response.status
      assert_equal I18n.t('general.not_found'), @response.parsed_body[:errors][0]
    end

    test 'should fail if the user is already in a guild' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      post invite_member_guilds_url, params: { user: { email: users(:guildless).email } }

      get accept_invitation_guilds_url, params: retrieve_params
      get accept_invitation_guilds_url, params: retrieve_params

      assert_equal 422, @response.status
      assert_equal I18n.t('guilds.already_in_a_guild'), @response.parsed_body[:errors][0]
    end

    test 'should succeed if the params are valid' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      post invite_member_guilds_url, params: { user: { email: users(:guildless).email } }

      get accept_invitation_guilds_url, params: retrieve_params

      assert_equal 200, @response.status
      assert_equal I18n.t('guilds.joined_successfully'), @response.parsed_body[:message]
    end

    private

    def retrieve_join_url
      email = Capybara.string(ActionMailer::Base.deliveries.last.to_s)
      page = email.first(:link, I18n.t('guilds.click_to_join'))

      page[:href]
    end

    def retrieve_params
      url = retrieve_join_url
      params = CGI.parse(URI.parse(url).query)

      { invitation_token: params['invitation_token'][0], user_id: params['user_id'][0] }
    end
  end
end

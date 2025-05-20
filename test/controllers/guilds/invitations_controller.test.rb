# frozen_string_literal: true

require 'test_helper'

class InvitationsControllerTest < ActionDispatch::IntegrationTest
  class InvitationShow < InvitationsControllerTest
    test 'should fail if the user is not logged in' do
      post guilds_invitation_url, params: { user: { email: users(:guildless) } }

      assert_equal 403, @response.status
      assert_equal I18n.t('errors.auth_fail'), @response.parsed_body[:error]
    end

    test 'should fail if the user is not found' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      post guilds_invitation_url, params: { user: { email: 'scoob@scoob.com' } }

      assert_equal 404, @response.status
      assert_equal I18n.t('errors.not_found'), @response.parsed_body[:error]
    end

    test 'should fail if the invited user is in a guild' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      post guilds_invitation_url, params: { user: { email: users(:guild_member).email } }

      assert_equal 404, @response.status
      assert_equal I18n.t('errors.not_found'), @response.parsed_body[:error]
    end

    test 'should send an email if all params are valid' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      post guilds_invitation_url, params: { user: { email: users(:guildless).email } }

      assert_equal 201, @response.status
      assert_equal I18n.t('guilds.invite_member_success'), @response.parsed_body[:message]
      assert_equal I18n.t('guilds.subject_invite'), ActionMailer::Base.deliveries.last.subject
    end
  end

  class InvitationCreate < InvitationsControllerTest
    test 'should fail if the invitation token is invalid or missing' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      get guilds_invitation_url

      assert_equal 422, @response.status
      assert_equal I18n.t('errors.invalid_token'), @response.parsed_body[:error]
    end

    test 'should fail if the user token is invalid or missing' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      post guilds_invitation_url, params: { user: { email: users(:guildless).email } }

      url = retrieve_join_url
      invitation_token = CGI.parse(URI.parse(url).query)['invitation_token'][0]
      get guilds_invitation_url, params: { invitation_token: invitation_token }

      assert_equal 422, @response.status
      assert_equal I18n.t('errors.invalid_token'), @response.parsed_body[:error]
    end

    test 'should fail if the user is already in a guild' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      post guilds_invitation_url, params: { user: { email: users(:guildless).email } }

      get guilds_invitation_url, params: retrieve_params
      get guilds_invitation_url, params: retrieve_params

      assert_equal 422, @response.status
      assert_equal I18n.t('errors.guilds.already_in_a_guild'), @response.parsed_body[:error]
    end

    test 'should succeed if the params are valid' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      post guilds_invitation_url, params: { user: { email: users(:guildless).email } }

      get guilds_invitation_url, params: retrieve_params

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

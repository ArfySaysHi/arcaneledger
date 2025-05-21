# frozen_string_literal: true

require 'test_helper'

class ActiveSessionsControllerTest < ActionDispatch::IntegrationTest
  class ActiveSessionsIndex < ActiveSessionsControllerTest
    test 'should fail if the user is not authenticated' do
      get active_sessions_url

      assert_equal 403, @response.status
      assert_equal I18n.t('errors.auth_fail'), @response.parsed_body[:error]
    end

    test 'should retrieve an array of active sessions if authenticated' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      user = @response.parsed_body[:user]

      get active_sessions_url

      body = @response.parsed_body

      assert_equal 200, @response.status
      assert_equal 1, body.count
      assert_equal user[:id], body[:data][0][:user_id]
    end
  end

  class ActiveSessionsDestroy < ActiveSessionsControllerTest
    test 'should fail if the user is not authenticated' do
      delete active_session_url(1)

      assert_equal 403, @response.status
      assert_equal I18n.t('errors.auth_fail'), @response.parsed_body[:error]
    end

    test 'should destroy the active session for the current user' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      get active_sessions_url
      session_id = @response.parsed_body[:data][0][:id]
      delete active_session_url(session_id)

      assert_equal 200, @response.status
      assert_equal I18n.t('active_sessions.destroy_success'), @response.parsed_body[:message]
    end
  end

  class ActiveSessionsDestroyAll < ActiveSessionsControllerTest
    test 'should fail if the user is not authenticated' do
      delete active_session_url(1)

      assert_equal 403, @response.status
      assert_equal I18n.t('errors.auth_fail'), @response.parsed_body[:error]
    end

    test 'should destroy all active sessions for the current user' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      delete destroy_all_active_sessions_url

      assert_equal 200, @response.status
      assert_equal I18n.t('active_sessions.destroy_success'), @response.parsed_body[:message]
    end
  end
end

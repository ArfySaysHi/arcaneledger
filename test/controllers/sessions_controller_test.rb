# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  class SessionsCreate < SessionsControllerTest
    test 'should return an error if the user does not exist' do
      post login_url, params: { user: { email: 'idontexist@nothere.com', password: 'words' } }

      body = @response.parsed_body

      assert_equal 422, @response.status
      assert_equal I18n.t('errors.sessions.invalid_login'), body[:error]
    end

    test 'should return an error if the user exists but is unconfirmed' do
      post login_url, params: { user: { email: users(:notconfirmed).email, password: 'password' } }

      body = @response.parsed_body

      assert_equal 422, @response.status
      assert_equal I18n.t('errors.sessions.invalid_login'), body[:error]
    end

    test 'should return an error if the user exists but password is wrong' do
      post login_url, params: { user: { email: users(:admin).email, password: 'wrong' } }

      body = @response.parsed_body

      assert_equal 422, @response.status
      assert_equal I18n.t('errors.sessions.invalid_login'), body[:error]
    end

    test 'should create the session if all the above are satisfied' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }

      body = @response.parsed_body

      assert_equal 201, @response.status
      assert_equal I18n.t('sessions.create_session'), body[:message]
      assert_equal users(:admin).email, body[:user][:email]
    end

    test 'should return an error if the user already has an active session' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }

      body = @response.parsed_body

      assert_equal 200, @response.status
      assert_equal I18n.t('sessions.already_present'), body[:message]
    end
  end

  class SessionsDestroy < SessionsControllerTest
    test 'should destroy the current session' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      delete logout_url

      body = @response.parsed_body

      assert_equal 200, @response.status
      assert_equal I18n.t('sessions.destroy_success'), body[:message]
    end
  end
end

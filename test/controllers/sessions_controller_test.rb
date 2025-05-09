# frozen_string_literal: true

require 'test_helper'

class SessionsControllerTest < ActionDispatch::IntegrationTest
  class SessionsCreate < SessionsControllerTest
    test 'should return an error if the user does not exist' do
      post login_url, params: { user: { email: 'idontexist@nothere.com', password: 'words' } }

      body = @response.parsed_body

      assert_equal 422, @response.status
      assert_equal I18n.t('sessions.default_error'), body[:errors][0]
    end

    test 'should return an error if the user exists but is unconfirmed' do
      post login_url, params: { user: { email: 'unconfirmed@unconfirmed.com', password: 'password' } }

      body = @response.parsed_body

      assert_equal 422, @response.status
      assert_equal I18n.t('sessions.default_error'), body[:errors][0]
    end

    test 'should return an error if the user exists but password is wrong' do
      post login_url, params: { user: { email: 'admin@admin.com', password: 'wrong' } }

      body = @response.parsed_body

      assert_equal 422, @response.status
      assert_equal I18n.t('sessions.default_error'), body[:errors][0]
    end

    test 'should create the session if all the above are satisfied' do
      post login_url, params: { user: { email: 'admin@admin.com', password: 'admin' } }

      body = @response.parsed_body

      assert_equal 201, @response.status
      assert_equal I18n.t('sessions.create_session'), body[:message]
    end

    test 'should return an error if the user already has an active session' do
      post login_url, params: { user: { email: 'admin@admin.com', password: 'admin' } }
      post login_url, params: { user: { email: 'admin@admin.com', password: 'admin' } }

      body = @response.parsed_body

      assert_equal 200, @response.status
      assert_equal I18n.t('sessions.already_present'), body[:message]
    end
  end

  class SessionsDestroy < SessionsControllerTest
    test 'should destroy the current session' do
      delete logout_url

      body = @response.parsed_body

      assert_equal 200, @response.status
      assert_equal I18n.t('sessions.destroy_session'), body[:message]
    end
  end
end

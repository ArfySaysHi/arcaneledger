# frozen_string_literal: true

require 'test_helper'

class ConfirmationsControllerTest < ActionDispatch::IntegrationTest
  class ConfirmationsCreate < ConfirmationsControllerTest
    test 'return an error if no user found' do
      post confirmations_url, params: { user: { email: 'idontexist@idontexist.com' } }

      body = @response.parsed_body

      assert_equal 404, @response.status
      assert_equal I18n.t('confirmations.cannot_find'), body[:errors][0]
    end

    test 'return an error if user is confirmed already' do
      post confirmations_url, params: { user: { email: 'admin@admin.com' } }

      body = @response.parsed_body

      assert_equal 404, @response.status
      assert_equal I18n.t('confirmations.cannot_find'), body[:errors][0]
    end

    test 'should send the confirmation email if the user is present and unconfirmed' do
      post confirmations_url, params: { user: { email: 'notconfirmed@arcaneledger.com' } }

      body = @response.parsed_body

      assert_equal 200, @response.status
      assert_equal I18n.t('confirmations.check_email'), body[:message]
      assert_equal I18n.t('users.subject_confirm'), ActionMailer::Base.deliveries.last.subject
    end

    # Should this be here? What if the same user wants to confirm another account?
    # I suppose just... hit logout...
    test 'return an error if the user is already logged in' do
      post login_url, params: { user: { email: 'admin@admin.com', password: 'admin' } }
      post confirmations_url, params: { user: { email: 'notconfirmed@arcaneledger.com' } }

      body = @response.parsed_body

      assert_equal 200, @response.status
      assert_equal I18n.t('sessions.already_present'), body[:message]
    end
  end

  class ConfirmationsEdit < ConfirmationsControllerTest
    test 'return an invalid token error if no user matches passed confirmation token' do
      get edit_confirmation_url('some_random_characters')

      body = @response.parsed_body

      assert_equal 422, @response.status
      assert_equal I18n.t('confirmations.token_invalid'), body[:errors][0]
    end

    test 'should confirm the user and return a confirmation message on success' do
      post confirmations_url, params: { user: { email: 'notconfirmed@arcaneledger.com' } }

      email = Capybara.string(ActionMailer::Base.deliveries.last.to_s)
      page = email.find(:link, I18n.t('confirmations.click_to_confirm'))
      url = page[:href]

      # Make the request to hit the edit endpoint
      get url

      assert_equal 200, @response.status
      assert_equal I18n.t('confirmations.confirmed'), @response.parsed_body[:message]
    end

    test 'return an error if the user is already logged in' do
      post login_url, params: { user: { email: 'admin@admin.com', password: 'admin' } }
      get edit_confirmation_url('some_random_characters')

      body = @response.parsed_body

      assert_equal 200, @response.status
      assert_equal I18n.t('sessions.already_present'), body[:message]
    end
  end
end

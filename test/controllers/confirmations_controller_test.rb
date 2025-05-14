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
      post confirmations_url, params: { user: { email: users(:admin).email } }

      body = @response.parsed_body

      assert_equal 404, @response.status
      assert_equal I18n.t('confirmations.cannot_find'), body[:errors][0]
    end

    test 'should send the confirmation email if the user is present and unconfirmed' do
      post confirmations_url, params: { user: { email: users(:notconfirmed).email } }

      body = @response.parsed_body

      assert_equal 200, @response.status
      assert_equal I18n.t('confirmations.check_email'), body[:message]
      assert_equal I18n.t('users.subject_confirm'), ActionMailer::Base.deliveries.last.subject
    end

    test 'should send the confirmation email if the user is reconfirming' do
      post confirmations_url, params: { user: { email: users(:notreconfirmed).email } }

      assert_equal 200, @response.status
      assert_equal I18n.t('confirmations.check_email'), @response.parsed_body[:message]
      assert_equal I18n.t('users.subject_confirm'), ActionMailer::Base.deliveries.last.subject
    end

    # Should this be here? What if the same user wants to confirm another account?
    # I suppose just... hit logout...
    test 'return an error if the user is already logged in' do
      post login_url, params: { user: { email: users(:notconfirmed).email, password: 'admin' } }
      post confirmations_url, params: { user: { email: users(:notconfirmed).email } }

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

    test 'should fail to confirm the user and return failed_confirm' do
      post confirmations_url, params: { user: { email: users(:notconfirmed).email } }
      url = retrieve_confirmation_url

      get url # Confirms the user
      delete logout_url # Logs out the user
      get url # Attempts to confirm an already confirmed user

      assert_equal 422, @response.status
      assert_equal I18n.t('confirmations.failed_confirm'), @response.parsed_body[:errors][0]
    end

    test 'should confirm the user and return a confirmation message on success' do
      post confirmations_url, params: { user: { email: users(:notconfirmed).email } }

      email = Capybara.string(ActionMailer::Base.deliveries.last.to_s)
      page = email.find(:link, I18n.t('confirmations.click_to_confirm'))
      url = page[:href]

      # Make the request to hit the edit endpoint
      get url

      assert_equal 200, @response.status
      assert_equal I18n.t('confirmations.confirmed'), @response.parsed_body[:message]
    end

    test 'return an error if the user is already logged in' do
      post login_url, params: { user: { email: users(:admin).email, password: 'admin' } }
      get edit_confirmation_url('some_random_characters')

      body = @response.parsed_body

      assert_equal 200, @response.status
      assert_equal I18n.t('sessions.already_present'), body[:message]
    end

    private

    def retrieve_confirmation_url
      email = Capybara.string(ActionMailer::Base.deliveries.last.to_s)
      page = email.find(:link, I18n.t('confirmations.click_to_confirm'))
      page[:href]
    end
  end
end

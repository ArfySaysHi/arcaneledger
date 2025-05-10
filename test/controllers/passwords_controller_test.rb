# frozen_string_literal: true

require 'test_helper'

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  class PasswordsCreate < PasswordsControllerTest
    test 'return false success if there is no user' do
      post passwords_url, params: { user: { email: 'menoexist@no.com' } }

      assert_equal 201, @response.status
      assert_equal I18n.t('passwords.create_success'), @response.parsed_body[:message]
    end

    test 'return failure if the user exists but is unconfirmed' do
      post passwords_url, params: { user: { email: 'notconfirmed@arcaneledger.com' } }

      assert_equal 422, @response.status
      assert_equal I18n.t('passwords.account_unconfirmed'), @response.parsed_body[:errors][0]
    end

    test 'send the email and return a success if a valid user is given' do
      post passwords_url, params: { user: { email: 'admin@admin.com' } }

      email = ActionMailer::Base.deliveries.last
      assert_equal I18n.t('users.subject_password_reset'), email.subject

      assert_equal 201, @response.status
      assert_equal I18n.t('passwords.create_success'), @response.parsed_body[:message]
    end

    test 'should interrupt the password reset if the user is already authed' do
      post login_url, params: { user: { email: 'admin@admin.com', password: 'admin' } }
      post passwords_url, params: { user: { email: 'admin@admin.com' } }

      assert_equal 200, @response.status
      assert_equal I18n.t('sessions.already_present'), @response.parsed_body[:message]
    end
  end

  class PasswordsEdit < PasswordsControllerTest
    test 'should interrupt the password reset if the user is already authed' do
      password_reset_token = retrieve_reset_token
      post login_url, params: { user: { email: 'admin@admin.com', password: 'admin' } }

      patch password_url(password_reset_token), params: {
        user: { password: 'newpass', password_confirmation: 'newpass' }, xhr: true
      }

      assert_equal 200, @response.status
      assert_equal I18n.t('sessions.already_present'), @response.parsed_body[:message]
    end

    test 'returns a failure if the user is not found' do
      patch password_url('totally_real_token_guys'), params: {
        user: { password: 'newpass', password_confirmation: 'newpass' }, xhr: true
      }

      assert_equal I18n.t('sessions.token_expired'), @response.parsed_body[:errors][0]
    end

    test 'returns a failure if the password and confirmation do not match' do
      patch password_url(retrieve_reset_token), params: {
        user: { password: 'nwpass', password_confirmation: 'newpass' }, xhr: true
      }

      assert_equal "Password confirmation doesn't match Password", @response.parsed_body[:errors][0]
    end

    test 'returns a success if a valid token is supplied' do
      patch password_url(retrieve_reset_token), params: {
        user: { password: 'newpass', password_confirmation: 'newpass' }, xhr: true
      }

      assert_equal I18n.t('passwords.update_success'), @response.parsed_body[:message]
    end

    private

    def retrieve_reset_token
      post passwords_url, params: { user: { email: 'admin@admin.com' } }

      email = Capybara.string(ActionMailer::Base.deliveries.last.to_s)
      url = email.find(:link, I18n.t('passwords.click_to_reset'))[:href]

      url.split('/')[4]
    end
  end
end

# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test 'should create user if valid data is provided' do
    post sign_up_url, params: { user: {
      email: 'email@email.com', password: 'password', password_confirmation: 'password'
    } }

    # Should send the confirmation email to the user
    assert_equal I18n.t('users.subject_confirm'), ActionMailer::Base.deliveries.last.subject

    # Should respond with a success
    assert_equal 201, @response.status
    assert_equal I18n.t('users.create_success'), @response.parsed_body[:message]
  end

  test 'should respond with errors if invalid data passed' do
    post sign_up_url, params: { user: { scoob: 'hey@raggy.com', password: 'jeepers' } }

    # No emails should have been sent
    assert_equal 0, ActionMailer::Base.deliveries.count

    # Should respond with failure
    assert_equal 422, @response.status
    body = @response.parsed_body
    assert_equal 2, body[:errors].count
    assert body[:errors].include? 'Email is invalid'
    assert body[:errors].include? "Email can't be blank"
  end

  test 'should respond that the user is already logged in if true' do
    post login_url, params: { user: { email: 'admin@admin.com', password: 'admin' } }

    post sign_up_url, params: { user: {
      email: 'admin@admin.com', password: 'admin', password_confirmation: 'admin'
    } }

    assert_equal 200, @response.status
    assert_equal I18n.t('sessions.already_present'), @response.parsed_body[:message]
  end
end

# frozen_string_literal: true

require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  def setup
    @user = users(:admin)
  end

  class Confirmation < UserMailerTest
    test 'should send confirmation email' do
      email = UserMailer.confirmation(@user, 'confirmation_token')

      assert_emails 1 do
        email.deliver_later
      end

      assert_equal email.to, [@user.email]
      assert_equal email.subject, I18n.t('users.subject_confirm')
    end

    test 'should use the unconfirmed_email if available' do
      user = User.create!(email: 'user@example.com', password_digest: BCrypt::Password.create('password'),
                          unconfirmed_email: 'other@email.com')
      email = UserMailer.confirmation(user, 'confirmation_token')

      assert_emails 1 do
        email.deliver_later
      end

      assert_equal email.to, [user.unconfirmed_email]
      assert_equal email.subject, I18n.t('users.subject_confirm')
    end
  end

  class PasswordReset < UserMailerTest
    test 'should send password reset email' do
      email = UserMailer.password_reset(@user, 'password_reset_token')

      assert_emails 1 do
        email.deliver_later
      end

      assert_equal email.to, [@user.email]
      assert_equal email.subject, I18n.t('users.subject_password_reset')
    end
  end
end

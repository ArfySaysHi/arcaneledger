# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  class UserValidation < UserTest
    test 'should fail if email invalid' do
      user = User.new(email: 'nah', password_digest: BCrypt::Password.create('nah'))
      assert_not user.valid?

      assert_raises(ActiveRecord::RecordInvalid, match: /Email is invalid/i) do
        user.validate!
      end
    end

    test 'should fail if email is not unique' do
      user = User.new(email: users(:admin).email, password_digest: BCrypt::Password.create('admin'))
      assert_not user.valid?

      assert_raises(ActiveRecord::RecordInvalid, match: /Email has already been taken/i) do
        user.validate!
      end
    end

    test 'should fail if email is missing' do
      user = User.new(password_digest: BCrypt::Password.create('admin'))
      assert_not user.valid?

      assert_raises(ActiveRecord::RecordInvalid, match: /Email can't be blank/i) do
        user.validate!
      end
    end

    test 'should fail if password is missing' do
      user = User.new(email: 'email@email.com')
      assert_not user.valid?

      assert_raises(ActiveRecord::RecordInvalid, match: /Password can't be blank/i) do
        user.validate!
      end
    end
  end

  class UserBeforeActions < UserTest
    test 'should downcase email on save' do
      user = User.new(email: 'UPPERCASE@HERE.COM', password_digest: BCrypt::Password.create('ayy'))

      user.save!
      assert_equal 'uppercase@here.com', User.last.email
    end
  end

  class UserConfirm < UserTest
    test 'returns false if the account is confirmed and not reconfirming' do
      user = User.create!(email: 'user@example.com', password_digest: BCrypt::Password.create('password'))

      user.confirm!
      assert_not user.confirm!
    end

    test 'should update the confirmed users email if an unconfirmed_email is present' do
      user = User.create!(email: 'user@example.com', password_digest: BCrypt::Password.create('password'))

      user.confirm!
      user.update(unconfirmed_email: 'new@email.com')
      user.confirm!

      assert_equal user.email, 'new@email.com'
    end

    test 'should set the confirmed_at time to now' do
      user = User.create!(email: 'user@example.com', password_digest: BCrypt::Password.create('password'))

      assert_nil user.confirmed_at
      user.confirm!
      assert user.confirmed_at
    end
  end

  class UserConfirmed < UserTest
    test 'should return if the user is confirmed' do
      user = User.create!(email: 'user@example.com', password_digest: BCrypt::Password.create('password'))

      assert_not user.confirmed?
      user.confirm!
      assert user.confirmed?
    end
  end

  class UserUnconfirmed < UserTest
    test 'should return if the user is unconfirmed' do
      user = User.create!(email: 'user@example.com', password_digest: BCrypt::Password.create('password'))

      assert user.unconfirmed?
      user.confirm!
      assert_not user.unconfirmed?
    end
  end

  class UserReconfirming < UserTest
    test 'should return if the user has a pending unconfirmed_email' do
      user = users(:admin)

      assert_not user.reconfirming?
      user.update(unconfirmed_email: 'user@newmail.com')
      assert user.reconfirming?
    end
  end

  class UserUnconfirmedOrReconfirming < UserTest
    test 'should return properly if the user has a pending unconfirmed_email' do
      user = users(:admin)

      assert_not user.unconfirmed_or_reconfirming?
      user.update(unconfirmed_email: 'user@newmail.com')
      assert user.unconfirmed_or_reconfirming?
    end

    test 'should return properly if the user is unconfirmed' do
      user = users(:notconfirmed)

      assert user.unconfirmed_or_reconfirming?
      user.confirm!
      assert_not user.unconfirmed_or_reconfirming?
    end
  end

  class UserConfirmableEmail < UserTest
    test 'should return the unconfirmed_email if available' do
      user = users(:notreconfirmed)

      assert_equal 'newemail@arcaneledger.com', user.confirmable_email
    end

    test 'should return the email if unconfirmed_email unavailable' do
      user = users(:admin)

      assert_equal 'admin@admin.com', user.confirmable_email
    end
  end

  class UserGenerateConfirmationToken < UserTest
    test 'should generate a valid signed_id token' do
      user = users(:admin)

      token = user.generate_confirmation_token
      assert User.find_signed(token, purpose: :confirm_email)
    end
  end

  class UserGeneratePasswordResetToken < UserTest
    test 'should generate a valid signed_id token' do
      user = users(:admin)

      token = user.generate_password_reset_token
      assert User.find_signed(token, purpose: :reset_password)
    end
  end

  class UserSendConfirmationEmail < UserTest
    test 'should send the confirmation email' do
      user = users(:notconfirmed)

      user.send_confirmation_email!
      assert_equal I18n.t('users.subject_confirm'), ActionMailer::Base.deliveries.last.subject
    end
  end

  class UserSendPasswordResetEmail < UserTest
    test 'should send the password reset email' do
      user = users(:notconfirmed)

      user.send_password_reset_email!
      assert_equal I18n.t('users.subject_password_reset'), ActionMailer::Base.deliveries.last.subject
    end
  end
end

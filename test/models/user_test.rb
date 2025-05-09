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
      user = User.new(email: 'admin@admin.com', password_digest: BCrypt::Password.create('admin'))
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

  class UserGenerateConfirmationToken < UserTest
    test 'should generate a valid signed_id token' do
      user = User.create!(email: 'user@example.com', password_digest: BCrypt::Password.create('password'))

      token = user.generate_confirmation_token
      assert User.find_signed(token, purpose: :confirm_email)
    end
  end

  class UserSendConfirmationEmail < UserTest
    test 'should send the confirmation email' do
      user = User.create!(email: 'user@example.com', password_digest: BCrypt::Password.create('password'))

      user.send_confirmation_email!
      assert_equal I18n.t('users.subject_confirm'), ActionMailer::Base.deliveries.last.subject
    end
  end
end

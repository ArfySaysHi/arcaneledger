# frozen_string_literal: true

# Handles confirmation only for now
class UserMailer < ApplicationMailer
  default from: User::MAILER_FROM_EMAIL

  def confirmation(user, confirmation_token)
    @user = user
    @confirmation_token = confirmation_token

    mail to: user.email, subject: I18n.t('users.subject_confirm')
  end

  def password_reset(user, password_reset_token)
    @user = user
    @password_reset_token = password_reset_token

    mail to: user.email, subject: I18n.t('users.subject_password_reset')
  end
end

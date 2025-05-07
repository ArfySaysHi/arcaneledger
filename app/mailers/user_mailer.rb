# frozen_string_literal: true

# Handles confirmation only for now
class UserMailer < ApplicationMailer
  SUBJECT_CONFIRM = 'Arcane Ledger Confirmation'

  default from: User::MAILER_FROM_EMAIL

  def confirmation(user, confirmation_token)
    @user = user
    @confirmation_token = confirmation_token

    mail to: user.email, subject: SUBJECT_CONFIRM
  end
end

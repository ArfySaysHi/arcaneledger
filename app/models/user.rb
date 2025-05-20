# frozen_string_literal: true

# Mostly handles user confirmation and some helpful functions
class User < ApplicationRecord
  CONFIRMATION_TOKEN_EXPIRATION = 10.minutes
  PASSWORD_RESET_TOKEN_EXPIRATION = 10.minutes
  FIND_USER_TOKEN_EXPIRATION = 10.minutes

  has_secure_password

  has_many :active_sessions, dependent: :destroy

  belongs_to :guild, optional: true

  before_save :downcase_email
  before_save :downcase_unconfirmed_email

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, presence: true, uniqueness: true
  validates :unconfirmed_email, format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }

  def confirm!
    return false unless unconfirmed_or_reconfirming?

    update(email: unconfirmed_email, unconfirmed_email: nil) if unconfirmed_email.present?
    update_columns(confirmed_at: Time.current)
  end

  def confirmed?
    confirmed_at.present?
  end

  def unconfirmed?
    !confirmed?
  end

  def reconfirming?
    unconfirmed_email.present?
  end

  def unconfirmed_or_reconfirming?
    unconfirmed? || reconfirming?
  end

  def guilded?
    guild_id.present?
  end

  def guildless?
    !guilded?
  end

  def confirmable_email
    return unconfirmed_email if unconfirmed_email.present?

    email
  end

  def generate_confirmation_token
    signed_id(expires_in: CONFIRMATION_TOKEN_EXPIRATION, purpose: :confirm_email)
  end

  def generate_password_reset_token
    signed_id(expires_in: PASSWORD_RESET_TOKEN_EXPIRATION, purpose: :reset_password)
  end

  def generate_find_user_token
    signed_id(expires_in: FIND_USER_TOKEN_EXPIRATION, purpose: :find_user)
  end

  def send_confirmation_email!
    confirmation_token = generate_confirmation_token
    UserMailer.confirmation(self, confirmation_token).deliver_now
  end

  def send_password_reset_email!
    password_reset_token = generate_password_reset_token
    UserMailer.password_reset(self, password_reset_token).deliver_now
  end

  private

  def downcase_email
    self.email = email.downcase
  end

  def downcase_unconfirmed_email
    return if unconfirmed_email.nil?

    self.unconfirmed_email = unconfirmed_email.downcase
  end
end

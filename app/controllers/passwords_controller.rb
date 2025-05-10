# frozen_string_literal: true

# Handles user password changes
class PasswordsController < ApplicationController
  before_action :cancel_if_authenticated

  # Generates our password reset token and emails it to the user
  # We can let the client handle throwing it to the update action
  # The client currently doesn't exist so we're just going to default it to a rails url
  def create
    user = User.find_by(email: params[:user][:email].downcase)

    password_create_success and return unless user.present?
    account_unconfirmed and return unless user.confirmed?

    user.send_password_reset_email!
    password_create_success
  end

  # Handles updating our users' password, expects a valid reset token
  def update
    user = User.find_signed(params[:password_reset_token], purpose: :reset_password)

    expired_token and return if user.nil?

    password_update_conditionals(user)
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def password_create_success
    render json: { message: I18n.t('passwords.create_success') }, status: :created
  end

  # Rubocop cyclomatic complexity is why this is here.
  def password_update_conditionals(user)
    account_unconfirmed and return unless user.present? && user.confirmed?
    password_update_success and return if user.update(password_params)

    render json: { errors: user.errors.full_messages }
  end

  def password_update_success
    render json: { message: I18n.t('passwords.update_success') }, status: :ok
  end

  def account_unconfirmed
    render json: { errors: [I18n.t('passwords.account_unconfirmed')] }, status: :unprocessable_entity
  end

  def expired_token
    render json: { errors: [I18n.t('sessions.token_expired')] }
  end
end

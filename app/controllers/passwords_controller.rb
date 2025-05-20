# frozen_string_literal: true

# Handles user password changes
class PasswordsController < ApplicationController
  before_action :cancel_if_authenticated

  rescue_from ActiveSupport::MessageVerifier::InvalidSignature, with: :expired_token

  # Generates our password reset token and emails it to the user
  # If the user does not exist, we fake a success to avoid timing attacks
  def create
    user = User.find_by(email: params[:user][:email].downcase)

    password_create_success and return unless user.present?
    account_unconfirmed and return unless user.confirmed?

    user.send_password_reset_email!
    password_create_success
  end

  # Handles updating our users' password, expects a valid reset token
  def update
    user = User.find_signed!(params[:password_reset_token], purpose: :reset_password)
    password_update_conditionals(user)
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # Rubocop cyclomatic complexity is why this is here.
  def password_update_conditionals(user)
    account_unconfirmed and return unless user.present? && user.confirmed?
    password_update_success and return if user.update(password_params)

    render json: { errors: user.errors.full_messages }
  end

  def password_create_success
    render_message!(:create_success, status: :created)
  end

  def password_update_success
    render_message!(:update_success, status: :ok)
  end

  def account_unconfirmed
    render_error!(:account_unconfirmed)
  end

  def expired_token
    render_error(:invalid_token, status: :forbidden)
  end
end

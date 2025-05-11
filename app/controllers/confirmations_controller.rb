# frozen_string_literal: true

# Handles account confirmation requests
class ConfirmationsController < ApplicationController
  before_action :cancel_if_authenticated, only: %i[create edit]

  def create
    user = User.find_by(email: params[:user][:email].downcase)

    cannot_find and return unless user.present? && user.unconfirmed?

    user.send_confirmation_email!
    render json: { message: I18n.t('confirmations.check_email') }
  end

  def edit
    user = User.find_signed(params[:confirmation_token], purpose: :confirm_email)

    token_invalid and return unless user.present?
    failed_confirm and return unless user.confirm!

    login user
    render json: { message: I18n.t('confirmations.confirmed') }
  end

  private

  def cannot_find
    render json: { errors: [I18n.t('confirmations.cannot_find')] }, status: :not_found
  end

  def token_invalid
    render json: { errors: [I18n.t('confirmations.token_invalid')] }, status: :unprocessable_content
  end

  def failed_confirm
    render json: { errors: [I18n.t('confirmations.failed_confirm')] }, status: :unprocessable_content
  end
end

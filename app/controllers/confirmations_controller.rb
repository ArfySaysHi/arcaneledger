# frozen_string_literal: true

# Handles account confirmation requests
class ConfirmationsController < ApplicationController
  before_action :cancel_if_authenticated, only: %i[create edit]

  def create
    user = User.find_by(email: params[:user][:email].downcase)

    if user.present? && user.unconfirmed?
      user.send_confirmation_email!

      render json: { message: I18n.t('confirmations.check_email') }
    else
      render json: { errors: [I18n.t('confirmations.cannot_find')] }, status: :not_found
    end
  end

  def edit
    user = User.find_signed(params[:confirmation_token], purpose: :confirm_email)

    if user.present?
      user.confirm!
      login user

      render json: { message: I18n.t('confirmations.confirmed') }
    else
      render json: { errors: [I18n.t('confirmations.token_invalid')] }, status: :unprocessable_content
    end
  end
end

# frozen_string_literal: true

# Handles account confirmation requests
class ConfirmationsController < ApplicationController
  before_action :cancel_if_authenticated, only: %i[create edit]

  def create
    user = User.find_by(email: params[:user][:email].downcase)

    cannot_find and return unless user.present? && user.unconfirmed_or_reconfirming?

    user.send_confirmation_email!
    render_message!(:check_email)
  end

  def edit
    user = User.find_signed(params[:confirmation_token], purpose: :confirm_email)

    token_invalid and return unless user.present?
    failed_confirm and return unless user.confirm!

    login user
    render_message!(:confirmed)
  end

  private

  def cannot_find
    render_error!(:cannot_find, status: :not_found)
  end

  def token_invalid
    render_error!(:token_invalid)
  end

  def failed_confirm
    render_error!(:failed_confirm)
  end
end

# frozen_string_literal: true

# Handles user account creation
class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[destroy update]
  before_action :cancel_if_authenticated, only: %i[create]

  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid

  def create
    user = User.new(create_user_params)

    if user.save
      user.send_confirmation_email!

      render json: { message: I18n.t('users.create_success') }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # Rubocop didn't like the conditionals in the controller so... there you go
  def update
    user = current_user

    update_user(user)
  end

  def destroy
    current_user.destroy
    reset_session

    render json: { message: I18n.t('users.destroy_success') }, status: :ok
  end

  private

  def create_user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end

  def update_user_params
    params.require(:user).permit(:password, :password_confirmation, :unconfirmed_email)
  end

  def update_user(user)
    incorrect_password and return unless user.authenticate(params[:user][:current_password])

    user.update!(update_user_params)
    update_new_email(user) and return if params[:user][:unconfirmed_email].present?

    render json: { message: I18n.t('users.update_success') }, status: :ok
  end

  def update_new_email(user)
    user.send_confirmation_email!
    render json: { message: I18n.t('confirmations.check_email') }, status: :ok
  end

  def incorrect_password
    render json: { errors: [I18n.t('sessions.incorrect_password')] }, status: :unprocessable_entity
  end

  def record_invalid(raised_error)
    render json: { errors: raised_error.record.errors.full_messages }, status: :unprocessable_entity
  end
end

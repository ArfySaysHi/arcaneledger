# frozen_string_literal: true

# Handles user account creation
class UsersController < ApplicationController
  before_action :authenticate_user!, only: %i[destroy update show]
  before_action :cancel_if_authenticated, only: %i[create]

  def show
    must_be_in_a_guild and return unless current_user.guild_id

    user = User.where(guild_id: current_user.guild_id).find(params[:id])
    render json: { message: I18n.t('users.show_success'), user: user }
  end

  def create
    user = User.new(create_user_params)

    if user.save
      user.send_confirmation_email!

      render json: { message: I18n.t('users.create_success') }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    incorrect_password and return unless current_user.authenticate(params[:user][:current_password])

    current_user.update!(update_user_params)
    update_new_email(current_user) and return if params[:user][:unconfirmed_email].present?

    render_message!(:update_success)
  end

  def destroy
    current_user.destroy
    reset_session

    render_message!(:destroy_success)
  end

  private

  def create_user_params
    params.expect(user: %i[email password password_confirmation])
  end

  def update_user_params
    params.expect(user: %i[password password_confirmation unconfirmed_email])
  end

  def update_new_email(user)
    user.send_confirmation_email!
    render_message('confirmations.check_email')
  end

  def incorrect_password
    render_error('sessions.incorrect_password')
  end

  def must_be_in_a_guild
    render_error('guilds.must_be_in_a_guild', status: :forbidden)
  end
end

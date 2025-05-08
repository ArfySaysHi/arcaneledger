# frozen_string_literal: true

# Creates and destroys application sessions
class SessionsController < ApplicationController
  before_action :cancel_if_authenticated, only: [:create]

  def create
    user = User.find_by(email: params[:user][:email].downcase)

    render_default_error and return unless user
    render_default_error and return if user.unconfirmed?
    render_default_error and return unless user.authenticate(params[:user][:password])

    handle_create_success(user)
  end

  def destroy
    logout
    render json: { message: I18n.t('sessions.destroy_session') }, status: :ok
  end

  private

  def handle_create_success(user)
    login user
    render json: { message: I18n.t('sessions.create_session') }, status: :created
  end

  def render_default_error
    render json: { errors: [I18n.t('sessions.default_error')] }, status: :unprocessable_entity
  end
end

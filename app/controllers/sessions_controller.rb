# frozen_string_literal: true

# Creates and destroys application sessions
class SessionsController < ApplicationController
  before_action :cancel_if_authenticated, only: %i[create]
  before_action :authenticate_user!, only: %i[destroy]

  def create
    user = User.find_by(email: params[:user][:email].downcase)

    render_default_error and return unless user
    render_default_error and return if user.unconfirmed?
    render_default_error and return unless create_session_auth

    handle_create_success(user)
  end

  def destroy
    logout
    forget_active_session

    render json: { message: I18n.t('sessions.destroy_session') }, status: :ok
  end

  private

  def create_session_auth
    User.authenticate_by(email: params[:user][:email].downcase, password: params[:user][:password])
  end

  def handle_create_success(user)
    active_session = login user
    remember(active_session) if params[:user][:remember_me] == '1'

    @message = I18n.t('sessions.create_session')
    @data = user

    render template: 'sessions/create', status: :created
  end

  def render_default_error
    render json: { errors: [I18n.t('sessions.default_error')] }, status: :unprocessable_entity
  end
end

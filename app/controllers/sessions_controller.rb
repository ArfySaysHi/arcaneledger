# frozen_string_literal: true

# Creates and destroys application sessions
class SessionsController < ApplicationController
  before_action :cancel_if_authenticated, only: %i[create]
  before_action :authenticate_user!, only: %i[destroy]

  def create
    user = User.find_by(email: params.dig(:user, :email)&.downcase)
    render_default_error and return unless create_valid?(user)

    handle_create_success(user)
  end

  def destroy
    logout
    forget_active_session

    render_message!(:destroy_success)
  end

  private

  def authenticate_user
    User.authenticate_by(email: params[:user][:email].downcase, password: params[:user][:password])
  end

  def create_valid?(user)
    return false unless user
    return false if user.unconfirmed?
    return false unless authenticate_user

    true
  end

  def handle_create_success(user)
    active_session = login user
    remember(active_session) if params[:user][:remember_me] == '1'

    @message = I18n.t('sessions.create_session')
    @data = user

    render template: 'sessions/create', status: :created
  end

  def render_default_error
    render_error!(:invalid_login)
  end
end

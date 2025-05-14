# frozen_string_literal: true

# Handles all Auth operations
module Authentication
  include ActionController::Cookies
  extend ActiveSupport::Concern

  included do
    before_action :current_user
  end

  def login(user)
    reset_session
    active_session = user.active_sessions.create!(user_agent: request.user_agent, ip_address: request.ip)
    session[:current_active_session_id] = active_session.id

    active_session
  end

  def logout
    active_session = ActiveSession.find_by(id: session[:current_active_session_id])
    reset_session
    active_session.destroy! if active_session.present?
  end

  def forget_active_session
    cookies.delete :remember_token
  end

  def remember(active_session)
    cookies.permanent.encrypted[:remember_token] = active_session.remember_token
  end

  def user_signed_in?
    Current.user.present?
  end

  def cancel_if_authenticated
    render json: { message: I18n.t('sessions.already_present') }, status: :ok and return if user_signed_in?
  end

  def authenticate_user!
    render json: { errors: [I18n.t('auth.auth_fail')] }, status: :forbidden and return unless user_signed_in?
  end

  private

  def current_user
    Current.user ||= retrieve_current_user
  end

  def retrieve_current_user
    session_present = session[:current_active_session_id].present?
    remember_token = cookies.permanent.encrypted[:remember_token]

    ActiveSession.find_by(id: session[:current_active_session_id])&.user and return if session_present
    ActiveSession.find_by(remember_token: remember_token)&.user and return if remember_token
  end
end

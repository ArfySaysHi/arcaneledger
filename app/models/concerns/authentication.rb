# frozen_string_literal: true

# Handles all Auth operations
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :current_user
  end

  def login(user)
    reset_session
    session[:current_user_id] = user.id
  end

  def logout
    reset_session
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
    Current.user ||= session[:current_user_id] && User.find_by(id: session[:current_user_id])
  end
end

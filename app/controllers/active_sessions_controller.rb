# frozen_string_literal: true

# Tracks active user sessions
class ActiveSessionsController < ApplicationController
  before_action :authenticate_user!

  def index
    render json: { data: current_user.active_sessions }, status: :ok
  end

  def destroy
    active_session = current_user.active_sessions.find(params[:id])
    active_session.destroy
    reset_session unless current_user

    render_destroy_session
  end

  def destroy_all
    forget_active_session
    current_user.active_sessions.destroy_all
    reset_session

    render_destroy_session
  end

  private

  def render_destroy_session
    render_message!(:destroy_session)
  end
end

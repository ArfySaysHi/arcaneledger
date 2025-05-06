# frozen_string_literal: true

# Creates and destroys application sessions
class SessionsController < ApplicationController
  before_action :cancel_if_authenticated, only: [:create]

  def create
    user = User.find_by(email: params[:user][:email].downcase)

    render_default_error unless user
    render_default_error if user.unconfirmed?
    render_default_error unless user.authenticate(params[:user][:password])

    handle_create_success(user)
  end

  def destroy
    logout
    render json: { message: 'Session destroyed.' }, status: :ok
  end

  private

  def handle_create_success(user)
    login user
    render json: { message: 'Session established.' }, status: :created
  end

  def render_default_error
    render json: { errors: ['Incorrect email or password.'] }, status: :unprocessable_entity
  end
end

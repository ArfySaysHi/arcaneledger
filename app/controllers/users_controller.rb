# frozen_string_literal: true

# Handles user account creation
class UsersController < ApplicationController
  CREATE_SUCCESS = 'User created successfully.'

  before_action :cancel_if_authenticated, only: [:create]

  def create
    user = User.new(user_params)

    if user.save
      user.send_confirmation_email!

      render json: { message: CREATE_SUCCESS }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end

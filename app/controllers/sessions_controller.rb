class SessionsController < ApplicationController
  before_action :cancel_if_authenticated, only: [ :create ]

  def create
    user = User.find_by(email: params[:user][:email].downcase)

    if user
      if user.unconfirmed?
        render_default_error
      elsif user.authenticate(params[:user][:password])
        login user
        render json: { message: "Session established." }, status: :created
      else
        render_default_error
      end
    else
      render_default_error
    end
  end

  def destroy
    logout
    render json: { message: "Session destroyed." }, status: :ok
  end

  private

  def render_default_error
      render json: { errors: ["Incorrect email or password."] }, status: :unprocessable_entity
  end
end

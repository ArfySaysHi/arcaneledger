class ConfirmationsController < ApplicationController
  before_action :cancel_if_authenticated, only: [ :create, :edit ]

  def create
    user = User.find_by(email: params[:user][:email].downcase)

    if user.present? && user.unconfirmed?
      user.send_confirmation_email!

      render json: { message: "Check your email to confirm your account." }
    else
      render json: { errors: ["No valid user found under that email address"] }, status: :not_found
    end
  end

  def edit
    user = User.find_signed(params[:confirmation_token], purpose: :confirm_email)

    if user.present?
      user.confirm!
      login user

      render json: { message: "Your account has been confirmed." }
    else
      render json: { errors: ["Invalid token supplied."] }, status: :unprocessable_content
    end
  end
end

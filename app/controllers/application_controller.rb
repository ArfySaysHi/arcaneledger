# frozen_string_literal: true

# All controllers inherit from this
class ApplicationController < ActionController::API
  include Authentication

  rescue_from ActiveRecord::RecordInvalid, with: :render_record_invalid
  rescue_from ActiveRecord::RecordNotFound, with: :render_record_not_found

  private

  def render_record_invalid(exc)
    render json: { errors: exc.record.errors.full_messages }, status: :unprocessable_entity
  end

  def render_record_not_found
    render json: { errors: [I18n.t('general.not_found')] }, status: :not_found
  end
end

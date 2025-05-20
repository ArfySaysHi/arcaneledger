# frozen_string_literal: true

# All controllers inherit from this
class ApplicationController < ActionController::API
  include Authentication

  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_invalid(exc)
    render json: { errors: exc.record.errors.full_messages }, status: :unprocessable_entity
  end

  def record_not_found
    render_error(:not_found, status: :not_found)
  end

  def render_error(id, status: :unprocessable_entity)
    render json: ErrorPayload.new(id, status), status: status
  end

  def render_error!(id, status: :unprocessable_entity)
    relative_id = format_class_to_id(id)
    render_error(relative_id, status: status)
  end

  def render_message(id, status: :ok)
    render json: { message: I18n.t(id) }, status: status
  end

  def render_message!(id, status: :ok)
    relative_id = format_class_to_id(id)
    render_message(relative_id, status: status)
  end

  def format_class_to_id(id)
    path = self.class.name.underscore.gsub('_controller', '').gsub('/', '.')

    "#{path}.#{id}"
  end
end

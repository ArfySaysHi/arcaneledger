# frozen_string_literal: true

# A generic error handler
class ErrorPayload
  attr_reader :id, :status

  def initialize(id, status)
    @id = id
    @status = status
  end

  def as_json(*)
    {
      status: Rack::Utils.status_code(status),
      code: id,
      error: I18n.t("errors.#{id}")
    }
  end
end

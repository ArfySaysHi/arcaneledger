# frozen_string_literal: true

# Tracks the current user session
class Current < ActiveSupport::CurrentAttributes
  attribute :user
end

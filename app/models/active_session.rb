# frozen_string_literal: true

# Holds session information
class ActiveSession < ApplicationRecord
  belongs_to :user
  has_secure_token :remember_token
end

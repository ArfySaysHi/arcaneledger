# frozen_string_literal: true

# Handles in-game time calculations
class GameTime < Time
  WORLD_CREATED_AT = 1_748_684_422
  TIME_SPEED_MOD = 8

  # A function that gets the current time in-game based on Time.now
  # Overwrites Time.current to take advantage of baseline rails calculations
  def self.current
    Time.zone.at((Time.zone.now - WORLD_CREATED_AT).to_i * TIME_SPEED_MOD)
  end
end

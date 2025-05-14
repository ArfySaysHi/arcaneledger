class AddRequestColumnsToActiveSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :active_sessions, :user_agent, :string
    add_column :active_sessions, :ip_address, :string
  end
end

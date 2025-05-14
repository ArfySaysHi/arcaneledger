class CreateActiveSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :active_sessions do |t|
      # Cascade so that the active_session will be destroyed if the corresponding user is
      t.references :user, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end

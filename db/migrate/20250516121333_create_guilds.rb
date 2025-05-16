class CreateGuilds < ActiveRecord::Migration[8.0]
  def change
    create_table :guilds do |t|
      t.string :name, null: false
      t.string :motto, null: false

      t.timestamps
    end

    add_index :guilds, :name, unique: true
  end
end

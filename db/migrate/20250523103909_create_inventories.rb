class CreateInventories < ActiveRecord::Migration[8.0]
  def change
    create_table :inventories do |t|
      t.references :guild, null: false, index: { unique: true }, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end

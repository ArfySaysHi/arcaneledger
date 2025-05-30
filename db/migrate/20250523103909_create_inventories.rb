class CreateInventories < ActiveRecord::Migration[8.0]
  def change
    create_table :inventories do |t|
      t.references :storable, null: false, polymorphic: true

      t.timestamps
    end

    add_index :inventories, [:storable_id, :storable_type], unique: true, name: 'by_storable'
  end
end

class CreateItems < ActiveRecord::Migration[8.0]
  def change
    create_table :items do |t|
      t.integer :amount, default: 0, null: false
      t.integer :price_on_acquisition, default: 0, null: false
      t.references :inventory, null: false, foreign_key: { on_delete: :cascade }
      t.references :commodity, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end

class CreateLedgers < ActiveRecord::Migration[8.0]
  def change
    create_table :ledgers do |t|
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.references :transaction_detail, null: false, foreign_key: { on_delete: :cascade }
      t.integer :amount, null: false
      t.integer :entry_type, null: false

      t.timestamps
    end
  end
end

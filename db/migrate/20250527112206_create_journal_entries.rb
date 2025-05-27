class CreateJournalEntries < ActiveRecord::Migration[8.0]
  def change
    create_table :journal_entries do |t|
      t.references :transaction_detail, null: false, foreign_key: { on_delete: :cascade }
      t.references :account, null: false, foreign_key: { on_delete: :cascade }
      t.integer :debit, default: 0
      t.integer :credit, default: 0

      t.timestamps
    end
  end
end

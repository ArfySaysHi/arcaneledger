class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.integer :account_type, null: false
      t.integer :balance, default: 0
      t.references :guild, null: false, foreign_key: { on_delete: :cascade }

      t.timestamps
    end
  end
end

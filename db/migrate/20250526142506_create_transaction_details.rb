class CreateTransactionDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :transaction_details do |t|
      t.date :transaction_date, null: false
      t.string :description

      t.timestamps
    end
  end
end

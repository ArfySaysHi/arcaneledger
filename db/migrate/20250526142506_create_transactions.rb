class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.date :transaction_date, null: false
      t.string :description

      t.timestamps
    end
  end
end

# frozen_string_literal: true

class CreateSupplierGoods < ActiveRecord::Migration[8.0]
  def change
    create_table :supplier_goods do |t|
      t.decimal :scarcity_mod, null: false
      t.references :commodity, null: false, foreign_key: true
      t.references :supplier, null: false, foreign_key: true

      t.timestamps
    end
  end
end

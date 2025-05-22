class CreateCommodities < ActiveRecord::Migration[8.0]
  def change
    create_table :commodities do |t|
      t.string :name, null: false
      t.text :description, null: false
      t.integer :value, null: false, default: 0
      t.integer :category, null: false, default: 0
      t.string :commodity_type, null: false
      t.string :origin, null: false
      t.string :unit, null: false
      t.datetime :expiry_date

      t.timestamps
    end

    add_index :commodities, :name, unique: true
    add_check_constraint :commodities, 'value >= 0', name: 'value_never_negative'
  end
end

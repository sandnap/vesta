class CreateInvestments < ActiveRecord::Migration[8.0]
  def change
    create_table :investments do |t|
      t.string :name, null: false
      t.string :symbol
      t.integer :exit_target_type
      t.decimal :current_units, precision: 18, scale: 8
      t.decimal :current_unit_price, precision: 18, scale: 8
      t.references :portfolio, null: false, foreign_key: true, index: true

      t.timestamps
    end

    add_index :investments, [ :portfolio_id, :name ], unique: true
    add_index :investments, [ :portfolio_id, :symbol ], unique: true, where: "symbol IS NOT NULL"
  end
end

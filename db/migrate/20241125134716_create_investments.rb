class CreateInvestments < ActiveRecord::Migration[7.1]
  def change
    create_table :investments do |t|
      t.references :portfolio, null: false, foreign_key: true
      t.string :name, null: false
      t.string :symbol
      t.integer :investment_type, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.decimal :current_units, precision: 18, scale: 8
      t.decimal :current_unit_price, precision: 18, scale: 8
      t.integer :exit_target_type

      t.timestamps
    end

    add_index :investments, [ :portfolio_id, :name ], unique: true
    add_index :investments, [ :portfolio_id, :symbol ], unique: true, where: "symbol IS NOT NULL"
  end
end

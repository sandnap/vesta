class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.datetime :transaction_date, null: false
      t.string :transaction_type, null: false
      t.decimal :units, null: false, precision: 18, scale: 8
      t.decimal :unit_price, null: false, precision: 18, scale: 8
      t.references :investment, null: false, foreign_key: true, index: true

      t.timestamps
    end

    add_index :transactions, [ :investment_id, :transaction_date ]
  end
end

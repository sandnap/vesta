class DropSymbolIndexOnInvestments < ActiveRecord::Migration[8.0]
  def change
    remove_index :investments, [ :portfolio_id, :symbol ]
  end
end

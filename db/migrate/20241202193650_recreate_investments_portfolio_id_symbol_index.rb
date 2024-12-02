class RecreateInvestmentsPortfolioIdSymbolIndex < ActiveRecord::Migration[8.0]
  def change
    remove_index :investments, [ :portfolio_id, :symbol ]
    add_index :investments, [ :portfolio_id, :symbol ], unique: true, where: "symbol IS NOT NULL;"
  end
end

class AddTypeToInvestments < ActiveRecord::Migration[8.0]
  def change
    add_column :investments, :investment_type, :integer, default: nil
  end
end

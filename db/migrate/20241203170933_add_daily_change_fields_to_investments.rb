class AddDailyChangeFieldsToInvestments < ActiveRecord::Migration[8.0]
  def change
    add_column :investments, :current_price_change, :decimal, precision: 18, scale: 8
    add_column :investments, :current_price_change_percent, :string
  end
end

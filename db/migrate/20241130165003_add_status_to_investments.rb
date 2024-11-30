class AddStatusToInvestments < ActiveRecord::Migration[8.0]
  def change
    add_column :investments, :status, :integer, default: 0
  end
end

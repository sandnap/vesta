class RemoveCurrentUnitFromInvestments < ActiveRecord::Migration[8.0]
  def change
    change_table :investments do |t|
      t.remove :current_units
    end
  end
end

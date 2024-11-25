class CreatePortfolios < ActiveRecord::Migration[8.0]
  def change
    create_table :portfolios do |t|
      t.string :name, null: false
      t.references :user, null: false, foreign_key: true, index: true

      t.timestamps
    end

    add_index :portfolios, [ :user_id, :name ], unique: true
  end
end

class CreateNotes < ActiveRecord::Migration[8.0]
  def change
    create_table :notes do |t|
      t.text :content, null: false
      t.integer :importance, null: false, default: 5
      t.references :notable, polymorphic: true, null: false, index: true

      t.timestamps
    end

    add_index :notes, [ :notable_type, :notable_id, :importance ]
  end
end

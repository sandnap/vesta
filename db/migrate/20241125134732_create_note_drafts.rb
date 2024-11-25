class CreateNoteDrafts < ActiveRecord::Migration[8.0]
  def change
    create_table :note_drafts do |t|
      t.text :content, null: false
      t.integer :importance, null: false, default: 5
      t.references :notable, polymorphic: true, null: false, index: true
      t.references :user, null: false, foreign_key: true, index: true
      t.datetime :last_autosaved_at, null: false

      t.timestamps
    end

    add_index :note_drafts, [ :notable_type, :notable_id, :user_id ], unique: true
  end
end

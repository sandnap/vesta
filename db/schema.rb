# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2024_12_03_221910) do
  create_table "investments", force: :cascade do |t|
    t.string "name", null: false
    t.string "symbol"
    t.string "exit_target_type"
    t.decimal "current_unit_price", precision: 18, scale: 8
    t.integer "portfolio_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.integer "investment_type"
    t.decimal "current_price_change", precision: 18, scale: 8
    t.string "current_price_change_percent"
    t.index ["portfolio_id", "name"], name: "index_investments_on_portfolio_id_and_name", unique: true
    t.index ["portfolio_id"], name: "index_investments_on_portfolio_id"
  end

  create_table "note_drafts", force: :cascade do |t|
    t.text "content", null: false
    t.integer "importance", default: 5, null: false
    t.string "notable_type", null: false
    t.integer "notable_id", null: false
    t.integer "user_id", null: false
    t.datetime "last_autosaved_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notable_type", "notable_id", "user_id"], name: "index_note_drafts_on_notable_type_and_notable_id_and_user_id", unique: true
    t.index ["notable_type", "notable_id"], name: "index_note_drafts_on_notable"
    t.index ["user_id"], name: "index_note_drafts_on_user_id"
  end

  create_table "notes", force: :cascade do |t|
    t.text "content", null: false
    t.integer "importance", default: 5, null: false
    t.string "notable_type", null: false
    t.integer "notable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notable_type", "notable_id", "importance"], name: "index_notes_on_notable_type_and_notable_id_and_importance"
    t.index ["notable_type", "notable_id"], name: "index_notes_on_notable"
  end

  create_table "portfolios", force: :cascade do |t|
    t.string "name", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_portfolios_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_portfolios_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "transactions", force: :cascade do |t|
    t.datetime "transaction_date", null: false
    t.string "transaction_type", null: false
    t.decimal "units", precision: 18, scale: 8, null: false
    t.decimal "unit_price", precision: 18, scale: 8, null: false
    t.integer "investment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["investment_id", "transaction_date"], name: "index_transactions_on_investment_id_and_transaction_date"
    t.index ["investment_id"], name: "index_transactions_on_investment_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "disabled", default: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "investments", "portfolios"
  add_foreign_key "note_drafts", "users"
  add_foreign_key "portfolios", "users"
  add_foreign_key "sessions", "users"
  add_foreign_key "transactions", "investments"
end

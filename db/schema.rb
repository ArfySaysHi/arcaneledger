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

ActiveRecord::Schema[8.0].define(version: 2025_05_26_123052) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "name", null: false
    t.integer "account_type", null: false
    t.integer "balance", default: 0
    t.bigint "guild_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guild_id"], name: "index_accounts_on_guild_id"
  end

  create_table "active_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.string "ip_address"
    t.string "remember_token", null: false
    t.index ["remember_token"], name: "index_active_sessions_on_remember_token", unique: true
    t.index ["user_id"], name: "index_active_sessions_on_user_id"
  end

  create_table "commodities", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.integer "value", default: 0, null: false
    t.integer "category", default: 0, null: false
    t.string "commodity_type", null: false
    t.string "origin", null: false
    t.string "unit", null: false
    t.datetime "expiry_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_commodities_on_name", unique: true
    t.check_constraint "value >= 0", name: "value_never_negative"
  end

  create_table "guilds", force: :cascade do |t|
    t.string "name", null: false
    t.string "motto", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_guilds_on_name", unique: true
  end

  create_table "inventories", force: :cascade do |t|
    t.bigint "guild_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["guild_id"], name: "index_inventories_on_guild_id", unique: true
  end

  create_table "items", force: :cascade do |t|
    t.integer "amount", default: 0, null: false
    t.integer "price_on_acquisition", default: 0, null: false
    t.bigint "inventory_id", null: false
    t.bigint "commodity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commodity_id"], name: "index_items_on_commodity_id"
    t.index ["inventory_id"], name: "index_items_on_inventory_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "confirmed_at"
    t.string "password_digest", null: false
    t.string "unconfirmed_email"
    t.bigint "guild_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["guild_id"], name: "index_users_on_guild_id"
  end

  add_foreign_key "accounts", "guilds", on_delete: :cascade
  add_foreign_key "active_sessions", "users", on_delete: :cascade
  add_foreign_key "inventories", "guilds", on_delete: :cascade
  add_foreign_key "items", "commodities", on_delete: :cascade
  add_foreign_key "items", "inventories", on_delete: :cascade
  add_foreign_key "users", "guilds"
end

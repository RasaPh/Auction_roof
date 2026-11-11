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

ActiveRecord::Schema[8.1].define(version: 2026_11_11_150000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "auctions", force: :cascade do |t|
    t.bigint "seller_id", null: false
    t.string "title", null: false
    t.text "description"
    t.decimal "starting_price", precision: 14, scale: 2, null: false
    t.decimal "min_increment", precision: 14, scale: 2
    t.decimal "current_price", precision: 14, scale: 2
    t.integer "bids_count", default: 0, null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.string "status", default: "draft", null: false
    t.bigint "winner_id"
    t.datetime "closed_at"
    t.datetime "ending_soon_notified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "auction_type", default: "english", null: false
    t.bigint "approved_by_id"
    t.datetime "approved_at"
    t.string "rejection_reason"
    t.index ["approved_by_id"], name: "index_auctions_on_approved_by_id"
    t.index ["seller_id"], name: "index_auctions_on_seller_id"
    t.index ["starts_at"], name: "index_auctions_on_starts_at"
    t.index ["status", "ends_at"], name: "index_auctions_on_status_and_ends_at"
    t.index ["winner_id"], name: "index_auctions_on_winner_id"
  end

  create_table "bids", force: :cascade do |t|
    t.bigint "auction_id", null: false
    t.bigint "user_id", null: false
    t.decimal "amount", precision: 14, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auction_id", "amount"], name: "index_bids_on_auction_id_and_amount"
    t.index ["auction_id"], name: "index_bids_on_auction_id"
    t.index ["user_id"], name: "index_bids_on_user_id"
  end

  create_table "chat_messages", force: :cascade do |t|
    t.bigint "auction_id", null: false
    t.bigint "user_id", null: false
    t.string "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auction_id"], name: "index_chat_messages_on_auction_id"
    t.index ["user_id"], name: "index_chat_messages_on_user_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "auction_id"
    t.string "kind", null: false
    t.string "message", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auction_id"], name: "index_notifications_on_auction_id"
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "product_categories", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_product_categories_on_name", unique: true
  end

  create_table "product_photos", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id", "position"], name: "index_product_photos_on_product_id_and_position"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "product_category_id", null: false
    t.string "name", null: false
    t.string "asset_code"
    t.text "description"
    t.string "owner_name", null: false
    t.string "owner_phone", null: false
    t.bigint "owner_user_id"
    t.text "owner_note"
    t.integer "quantity", default: 1, null: false
    t.string "unit", default: "ชิ้น", null: false
    t.string "condition", default: "usable", null: false
    t.string "location_province"
    t.decimal "appraised_price", precision: 14, scale: 2
    t.string "status", default: "draft", null: false
    t.bigint "created_by_id"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["asset_code"], name: "index_products_on_asset_code", unique: true, where: "(asset_code IS NOT NULL)"
    t.index ["created_by_id"], name: "index_products_on_created_by_id"
    t.index ["owner_user_id"], name: "index_products_on_owner_user_id"
    t.index ["product_category_id"], name: "index_products_on_product_category_id"
    t.index ["status"], name: "index_products_on_status"
    t.index ["updated_by_id"], name: "index_products_on_updated_by_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.json "permissions", default: [], null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "phone", null: false
    t.string "email_address"
    t.string "password_digest", null: false
    t.string "otp_digest"
    t.datetime "otp_expires_at"
    t.integer "otp_attempts", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "role_id"
    t.index ["phone"], name: "index_users_on_phone", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "auctions", "users", column: "approved_by_id"
  add_foreign_key "auctions", "users", column: "seller_id"
  add_foreign_key "auctions", "users", column: "winner_id"
  add_foreign_key "bids", "auctions"
  add_foreign_key "bids", "users"
  add_foreign_key "chat_messages", "auctions"
  add_foreign_key "chat_messages", "users"
  add_foreign_key "notifications", "auctions"
  add_foreign_key "notifications", "users"
  add_foreign_key "product_photos", "products"
  add_foreign_key "products", "product_categories"
  add_foreign_key "products", "users", column: "created_by_id"
  add_foreign_key "products", "users", column: "owner_user_id"
  add_foreign_key "products", "users", column: "updated_by_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "roles"
end

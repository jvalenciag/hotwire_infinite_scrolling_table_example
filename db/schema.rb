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

ActiveRecord::Schema[8.1].define(version: 2025_12_16_000215) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "brands", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.virtual "searchable", type: :tsvector, as: "(setweight(to_tsvector('simple'::regconfig, (name)::text), 'A'::\"char\") || setweight(to_tsvector('simple'::regconfig, (short_name)::text), 'B'::\"char\"))", stored: true
    t.string "short_name"
    t.datetime "updated_at", null: false
    t.index ["searchable"], name: "index_brands_on_searchable", using: :gin
  end

  create_table "products", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.datetime "created_at", null: false
    t.datetime "deleted_at", precision: nil
    t.string "description"
    t.boolean "enabled", default: true, null: false
    t.string "model"
    t.string "name"
    t.virtual "searchable", type: :tsvector, as: "(setweight(to_tsvector('simple'::regconfig, (name)::text), 'A'::\"char\") || setweight(to_tsvector('simple'::regconfig, (description)::text), 'B'::\"char\"))", stored: true
    t.string "sku"
    t.datetime "updated_at", null: false
    t.index ["brand_id"], name: "index_products_on_brand_id"
    t.index ["searchable"], name: "index_products_on_searchable", using: :gin
  end

  add_foreign_key "products", "brands"
end

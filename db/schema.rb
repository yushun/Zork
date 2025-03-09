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

ActiveRecord::Schema[8.0].define(version: 2025_03_09_072118) do
  create_table "exits", force: :cascade do |t|
    t.integer "room_id"
    t.integer "destination_id"
    t.string "direction"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["destination_id"], name: "index_exits_on_destination_id"
    t.index ["room_id"], name: "index_exits_on_room_id"
  end

  create_table "items", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "item_type"
    t.integer "room_id"
    t.integer "player_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "weight"
    t.boolean "is_carriable"
    t.boolean "is_equipped"
    t.integer "armor_rating"
    t.integer "damage"
    t.integer "container_id"
    t.index ["container_id"], name: "index_items_on_container_id"
    t.index ["player_id"], name: "index_items_on_player_id"
    t.index ["room_id"], name: "index_items_on_room_id"
  end

  create_table "players", force: :cascade do |t|
    t.integer "current_room_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["current_room_id"], name: "index_players_on_current_room_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "items", "items", column: "container_id"
end

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

ActiveRecord::Schema[8.0].define(version: 2025_10_16_042627) do
  create_table "posts", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.text "content"
    t.text "excerpt"
    t.string "category"
    t.string "author_name"
    t.string "author_avatar"
    t.datetime "published_at"
    t.boolean "featured", default: false
    t.string "featured_image"
    t.string "image_caption"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "author_url"
    t.text "author_bio"
    t.string "author_social_url"
    t.index ["category"], name: "index_posts_on_category"
    t.index ["featured"], name: "index_posts_on_featured"
    t.index ["published_at"], name: "index_posts_on_published_at"
    t.index ["slug"], name: "index_posts_on_slug", unique: true
  end
end

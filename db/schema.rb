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

ActiveRecord::Schema.define(version: 2026_04_06_162233) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "vector"

  create_table "outreach_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "resume_id", null: false
    t.string "recipient_email"
    t.string "recipient_name"
    t.string "subject"
    t.text "body"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["resume_id"], name: "index_outreach_logs_on_resume_id"
    t.index ["user_id"], name: "index_outreach_logs_on_user_id"
  end

  create_table "resumes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "filename"
    t.text "content_text"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.vector "embedding", limit: 768
    t.string "file_path"
    t.index ["user_id"], name: "index_resumes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "username"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.string "gemini_api_key"
    t.string "smtp_user"
    t.string "smtp_pass"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "outreach_logs", "resumes"
  add_foreign_key "outreach_logs", "users"
  add_foreign_key "resumes", "users"
end

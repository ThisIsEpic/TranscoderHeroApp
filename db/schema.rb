# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160705215234) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "apps", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "access_token"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "url"
    t.string   "encrypted_s3_access_key_id"
    t.string   "encrypted_s3_secret_access_key"
    t.string   "encrypted_s3_access_key_id_iv"
    t.string   "encrypted_s3_secret_access_key_iv"
    t.string   "s3_output_bucket"
    t.index ["user_id"], name: "index_apps_on_user_id", using: :btree
  end

  create_table "job_profiles", force: :cascade do |t|
    t.string   "name"
    t.integer  "app_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_id"], name: "index_job_profiles_on_app_id", using: :btree
  end

  create_table "transcoding_jobs", force: :cascade do |t|
    t.integer  "app_id"
    t.string   "input"
    t.json     "override"
    t.json     "profiles"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "state"
    t.boolean  "webhook_delivered",        default: false
    t.datetime "last_webhook_sent_at"
    t.integer  "webhook_delivery_retries", default: 0
    t.string   "webhook_url"
    t.json     "output_data"
    t.index ["app_id"], name: "index_transcoding_jobs_on_app_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "apps", "users"
  add_foreign_key "job_profiles", "apps"
  add_foreign_key "transcoding_jobs", "apps"
end

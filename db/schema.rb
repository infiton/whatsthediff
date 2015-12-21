# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20151219143650) do

  create_table "project_rows", force: :cascade do |t|
    t.integer  "project_id", limit: 4
    t.integer  "data_type",  limit: 4
    t.string   "uid",        limit: 255
    t.string   "digest",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "project_rows", ["data_type"], name: "index_project_rows_on_data_type", using: :btree
  add_index "project_rows", ["digest"], name: "index_project_rows_on_digest", using: :btree
  add_index "project_rows", ["project_id"], name: "fk_rails_58baa0d94a", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "state",           limit: 255
    t.integer  "user_id",         limit: 4
    t.integer  "target_user_id",  limit: 4
    t.string   "field_signature", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "projects", ["target_user_id"], name: "index_projects_on_target_user_id", using: :btree
  add_index "projects", ["user_id"], name: "fk_rails_b872a6760a", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.string   "company",    limit: 255
    t.string   "email",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree

  add_foreign_key "project_rows", "projects"
  add_foreign_key "projects", "users"
end

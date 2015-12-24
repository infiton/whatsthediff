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

ActiveRecord::Schema.define(version: 20151224043309) do

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "project_results", force: :cascade do |t|
    t.integer "project_id",  limit: 4
    t.string  "result_type", limit: 255
    t.string  "filename",    limit: 255
  end

  add_index "project_results", ["project_id"], name: "fk_rails_c08d7c38d0", using: :btree
  add_index "project_results", ["result_type"], name: "index_project_results_on_result_type", using: :btree

  create_table "project_rows", force: :cascade do |t|
    t.integer  "project_id", limit: 4
    t.string   "data_type",  limit: 255
    t.string   "uid",        limit: 255
    t.string   "digest",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "project_rows", ["data_type"], name: "index_project_rows_on_data_type", using: :btree
  add_index "project_rows", ["digest"], name: "index_project_rows_on_digest", using: :btree
  add_index "project_rows", ["project_id"], name: "fk_rails_58baa0d94a", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "slug",            limit: 255
    t.string   "state",           limit: 255
    t.integer  "user_id",         limit: 4
    t.integer  "target_user_id",  limit: 4
    t.string   "field_signature", limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "projects", ["slug"], name: "index_projects_on_slug", using: :btree
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

  add_foreign_key "project_results", "projects"
  add_foreign_key "project_rows", "projects"
  add_foreign_key "projects", "users"
end

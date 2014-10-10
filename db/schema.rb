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

ActiveRecord::Schema.define(version: 20141010120529) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "folders", force: true do |t|
    t.string   "title",        null: false
    t.string   "pretty_title"
    t.boolean  "browsable"
    t.integer  "space_id",     null: false
    t.integer  "folder_id"
    t.integer  "user_id",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "folders", ["folder_id"], name: "index_folders_on_folder_id", using: :btree
  add_index "folders", ["space_id"], name: "index_folders_on_space_id", using: :btree
  add_index "folders", ["user_id"], name: "index_folders_on_user_id", using: :btree

  create_table "page_carbon_copies", force: true do |t|
    t.text     "content"
    t.integer  "page_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "page_carbon_copies", ["page_id"], name: "index_page_carbon_copies_on_page_id", unique: true, using: :btree

  create_table "page_revisions", force: true do |t|
    t.binary   "blob"
    t.string   "version"
    t.integer  "additions",  limit: 8
    t.integer  "deletions",  limit: 8
    t.integer  "patchsz",    limit: 8
    t.integer  "page_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "page_revisions", ["created_at"], name: "index_page_revisions_on_created_at", using: :btree
  add_index "page_revisions", ["page_id"], name: "index_page_revisions_on_page_id", using: :btree
  add_index "page_revisions", ["user_id"], name: "index_page_revisions_on_user_id", using: :btree

  create_table "pages", force: true do |t|
    t.string   "title",        null: false
    t.string   "pretty_title"
    t.text     "content"
    t.boolean  "browsable"
    t.integer  "folder_id"
    t.integer  "user_id",      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["folder_id"], name: "index_pages_on_folder_id", using: :btree
  add_index "pages", ["pretty_title"], name: "index_pages_on_pretty_title", using: :btree
  add_index "pages", ["user_id"], name: "index_pages_on_user_id", using: :btree

  create_table "space_users", id: false, force: true do |t|
    t.integer  "role",       default: 0, null: false
    t.integer  "user_id"
    t.integer  "space_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "space_users", ["space_id", "role"], name: "index_space_users_on_space_id_and_role", using: :btree
  add_index "space_users", ["space_id"], name: "index_space_users_on_space_id", using: :btree
  add_index "space_users", ["user_id", "space_id"], name: "index_space_users_on_user_id_and_space_id", unique: true, using: :btree
  add_index "space_users", ["user_id"], name: "index_space_users_on_user_id", using: :btree

  create_table "spaces", force: true do |t|
    t.string   "title",                        null: false
    t.string   "pretty_title"
    t.text     "brief"
    t.boolean  "is_public",    default: false
    t.text     "preferences"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "spaces", ["user_id"], name: "index_spaces_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "name",                                   null: false
    t.string   "nickname",                               null: false
    t.boolean  "auto_nickname",          default: false
    t.string   "gravatar_email"
    t.text     "preferences"
    t.string   "email",                                  null: false
    t.string   "encrypted_password",                     null: false
    t.string   "password_salt"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["nickname"], name: "index_users_on_nickname", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "folders", "folders", name: "folders_folder_id_fk"
  add_foreign_key "folders", "spaces", name: "folders_space_id_fk"
  add_foreign_key "folders", "users", name: "folders_user_id_fk"

  add_foreign_key "page_carbon_copies", "pages", name: "page_carbon_copies_page_id_fk"

  add_foreign_key "page_revisions", "pages", name: "page_revisions_page_id_fk"
  add_foreign_key "page_revisions", "users", name: "page_revisions_user_id_fk"

  add_foreign_key "pages", "folders", name: "pages_folder_id_fk"
  add_foreign_key "pages", "users", name: "pages_user_id_fk"

  add_foreign_key "space_users", "spaces", name: "space_users_space_id_fk"
  add_foreign_key "space_users", "users", name: "space_users_user_id_fk"

  add_foreign_key "spaces", "users", name: "spaces_user_id_fk"

end

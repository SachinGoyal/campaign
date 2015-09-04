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

ActiveRecord::Schema.define(version: 20150904071015) do

  create_table "attributes", force: :cascade do |t|
    t.integer  "company_id",  limit: 4
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.boolean  "status",      limit: 1
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "attributes", ["company_id"], name: "index_attributes_on_company_id", using: :btree

  create_table "campeigns", force: :cascade do |t|
    t.integer  "user_id",     limit: 4
    t.string   "name",        limit: 255
    t.text     "description", limit: 65535
    t.boolean  "status",      limit: 1
    t.integer  "created_by",  limit: 4
    t.integer  "updated_by",  limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "campeigns", ["user_id"], name: "index_campeigns_on_user_id", using: :btree

  create_table "companies", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.integer  "free_emails", limit: 4
    t.boolean  "status",      limit: 1
    t.integer  "created_by",  limit: 4
    t.integer  "updated_by",  limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.integer  "company_id", limit: 4
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.string   "email",      limit: 255
    t.boolean  "status",     limit: 1
    t.integer  "created_by", limit: 4
    t.integer  "updated_by", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "contacts", ["company_id"], name: "index_contacts_on_company_id", using: :btree

  create_table "contacts_attributes", id: false, force: :cascade do |t|
    t.integer "contact_id",   limit: 4, null: false
    t.integer "attribute_id", limit: 4, null: false
  end

  add_index "contacts_attributes", ["attribute_id"], name: "index_contacts_attributes_on_attribute_id", using: :btree
  add_index "contacts_attributes", ["contact_id"], name: "index_contacts_attributes_on_contact_id", using: :btree

  create_table "contacts_newsletters", id: false, force: :cascade do |t|
    t.integer "contact_id",    limit: 4, null: false
    t.integer "newsletter_id", limit: 4, null: false
  end

  add_index "contacts_newsletters", ["contact_id"], name: "index_contacts_newsletters_on_contact_id", using: :btree
  add_index "contacts_newsletters", ["newsletter_id"], name: "index_contacts_newsletters_on_newsletter_id", using: :btree

  create_table "contacts_profiles", id: false, force: :cascade do |t|
    t.integer "contact_id", limit: 4, null: false
    t.integer "profile_id", limit: 4, null: false
  end

  add_index "contacts_profiles", ["contact_id"], name: "index_contacts_profiles_on_contact_id", using: :btree
  add_index "contacts_profiles", ["profile_id"], name: "index_contacts_profiles_on_profile_id", using: :btree

  create_table "newsletters", force: :cascade do |t|
    t.integer  "campeign_id",  limit: 4
    t.integer  "template_id",  limit: 4
    t.string   "name",         limit: 255
    t.string   "subject",      limit: 255
    t.string   "from_name",    limit: 255
    t.string   "from_address", limit: 255
    t.string   "reply_email",  limit: 255
    t.integer  "created_by",   limit: 4
    t.integer  "updated_by",   limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "newsletters", ["campeign_id"], name: "index_newsletters_on_campeign_id", using: :btree
  add_index "newsletters", ["template_id"], name: "index_newsletters_on_template_id", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.integer  "company_id", limit: 4
    t.string   "name",       limit: 255
    t.boolean  "status",     limit: 1
    t.integer  "created_by", limit: 4
    t.integer  "updated_by", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "profiles", ["company_id"], name: "index_profiles_on_company_id", using: :btree

  create_table "profiles_newsletters", id: false, force: :cascade do |t|
    t.integer "profile_id",    limit: 4, null: false
    t.integer "newsletter_id", limit: 4, null: false
  end

  add_index "profiles_newsletters", ["newsletter_id"], name: "index_profiles_newsletters_on_newsletter_id", using: :btree
  add_index "profiles_newsletters", ["profile_id"], name: "index_profiles_newsletters_on_profile_id", using: :btree

  create_table "settings", force: :cascade do |t|
    t.integer  "user_id",              limit: 4
    t.string   "site_title",           limit: 255
    t.string   "admin_email",          limit: 255
    t.string   "admin_footer_content", limit: 255
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "settings", ["user_id"], name: "index_settings_on_user_id", using: :btree

  create_table "templates", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.string   "name",       limit: 255
    t.text     "content",    limit: 65535
    t.boolean  "status",     limit: 1
    t.integer  "created_by", limit: 4
    t.integer  "updated_by", limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "templates", ["user_id"], name: "index_templates_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "attributes", "companies"
  add_foreign_key "campeigns", "users"
  add_foreign_key "contacts", "companies"
  add_foreign_key "contacts_attributes", "attributes"
  add_foreign_key "contacts_attributes", "contacts"
  add_foreign_key "contacts_newsletters", "contacts"
  add_foreign_key "contacts_newsletters", "newsletters"
  add_foreign_key "contacts_profiles", "contacts"
  add_foreign_key "contacts_profiles", "profiles"
  add_foreign_key "newsletters", "campeigns"
  add_foreign_key "newsletters", "templates"
  add_foreign_key "profiles", "companies"
  add_foreign_key "profiles_newsletters", "newsletters"
  add_foreign_key "profiles_newsletters", "profiles"
  add_foreign_key "settings", "users"
  add_foreign_key "templates", "users"
end

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

ActiveRecord::Schema.define(version: 20150910062649) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attributes", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "name"
    t.text     "description"
    t.boolean  "status"
    t.datetime "deleted_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "attributes", ["company_id"], name: "index_attributes_on_company_id", using: :btree

  create_table "campeigns", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "description"
    t.boolean  "status"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "deleted_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "campeigns", ["user_id"], name: "index_campeigns_on_user_id", using: :btree

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.integer  "free_emails"
    t.boolean  "status"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "deleted_at"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.boolean  "status"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "contacts", ["company_id"], name: "index_contacts_on_company_id", using: :btree

  create_table "contacts_attributes", id: false, force: :cascade do |t|
    t.integer "contact_id",   null: false
    t.integer "attribute_id", null: false
  end

  add_index "contacts_attributes", ["attribute_id"], name: "index_contacts_attributes_on_attribute_id", using: :btree
  add_index "contacts_attributes", ["contact_id"], name: "index_contacts_attributes_on_contact_id", using: :btree

  create_table "contacts_newsletters", id: false, force: :cascade do |t|
    t.integer "contact_id",    null: false
    t.integer "newsletter_id", null: false
  end

  add_index "contacts_newsletters", ["contact_id"], name: "index_contacts_newsletters_on_contact_id", using: :btree
  add_index "contacts_newsletters", ["newsletter_id"], name: "index_contacts_newsletters_on_newsletter_id", using: :btree

  create_table "contacts_profiles", id: false, force: :cascade do |t|
    t.integer "contact_id", null: false
    t.integer "profile_id", null: false
  end

  add_index "contacts_profiles", ["contact_id"], name: "index_contacts_profiles_on_contact_id", using: :btree
  add_index "contacts_profiles", ["profile_id"], name: "index_contacts_profiles_on_profile_id", using: :btree

  create_table "functions", force: :cascade do |t|
    t.string   "controller"
    t.string   "action"
    t.string   "agroup"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "functions_roles", id: false, force: :cascade do |t|
    t.integer "function_id", null: false
    t.integer "role_id",     null: false
  end

  add_index "functions_roles", ["function_id"], name: "index_functions_roles_on_function_id", using: :btree
  add_index "functions_roles", ["role_id"], name: "index_functions_roles_on_role_id", using: :btree

  create_table "newsletters", force: :cascade do |t|
    t.integer  "campeign_id"
    t.integer  "template_id"
    t.string   "name"
    t.string   "subject"
    t.string   "from_name"
    t.string   "from_address"
    t.string   "reply_email"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "deleted_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "newsletters", ["campeign_id"], name: "index_newsletters_on_campeign_id", using: :btree
  add_index "newsletters", ["template_id"], name: "index_newsletters_on_template_id", using: :btree

  create_table "profiles", force: :cascade do |t|
    t.integer  "company_id"
    t.string   "name"
    t.boolean  "status"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "profiles", ["company_id"], name: "index_profiles_on_company_id", using: :btree

  create_table "profiles_newsletters", id: false, force: :cascade do |t|
    t.integer "profile_id",    null: false
    t.integer "newsletter_id", null: false
  end

  add_index "profiles_newsletters", ["newsletter_id"], name: "index_profiles_newsletters_on_newsletter_id", using: :btree
  add_index "profiles_newsletters", ["profile_id"], name: "index_profiles_newsletters_on_profile_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "site_title"
    t.string   "admin_email"
    t.string   "admin_footer_content"
    t.datetime "deleted_at"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "settings", ["user_id"], name: "index_settings_on_user_id", using: :btree

  create_table "templates", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "name"
    t.text     "content"
    t.boolean  "status"
    t.integer  "created_by"
    t.integer  "updated_by"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "templates", ["user_id"], name: "index_templates_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.integer  "role_id",                             null: false
    t.string   "user_type"
    t.string   "username",               default: "", null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "deleted_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
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
  add_foreign_key "functions_roles", "functions"
  add_foreign_key "functions_roles", "roles"
  add_foreign_key "newsletters", "campeigns"
  add_foreign_key "newsletters", "templates"
  add_foreign_key "profiles", "companies"
  add_foreign_key "profiles_newsletters", "newsletters"
  add_foreign_key "profiles_newsletters", "profiles"
  add_foreign_key "settings", "users"
  add_foreign_key "templates", "users"
end

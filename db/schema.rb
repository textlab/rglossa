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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121009170823) do

  create_table "corpora", :force => true do |t|
    t.string   "name",             :null => false
    t.integer  "default_max_hits"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "corpus_texts", :force => true do |t|
    t.integer  "language_config_id"
    t.string   "uri"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "deleted_hits", :force => true do |t|
    t.integer  "search_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "metadata_categories", :force => true do |t|
    t.integer  "corpus_id"
    t.string   "name",       :null => false
    t.string   "value_type", :null => false
    t.string   "selector"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "type"
  end

  create_table "metadata_values", :force => true do |t|
    t.integer "metadata_category_id"
    t.string  "type"
    t.text    "text_value"
    t.integer "integer_value"
    t.boolean "boolean_value"
  end

  create_table "searches", :force => true do |t|
    t.integer  "owner_id"
    t.text     "queries",            :null => false
    t.text     "search_options"
    t.text     "metadata_selection"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

end

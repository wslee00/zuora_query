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

ActiveRecord::Schema.define(:version => 20131109043907) do

  create_table "connectors", :force => true do |t|
    t.string   "username"
    t.string   "password"
    t.string   "url"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "connector_type"
    t.string   "name"
    t.text     "window_state"
    t.integer  "num_limit"
    t.string   "order_by_field"
    t.string   "order_by_direction"
    t.text     "editor_state"
    t.string   "key"
  end

  create_table "query_results", :force => true do |t|
    t.integer  "connector_id"
    t.text     "query"
    t.text     "header_row"
    t.text     "data_rows"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "query_tool_states", :force => true do |t|
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "last_connector_id"
  end

end

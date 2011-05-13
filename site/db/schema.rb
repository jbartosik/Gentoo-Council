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

ActiveRecord::Schema.define(:version => 20110523175740) do

  create_table "agendas", :force => true do |t|
    t.datetime "meeting_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",         :default => "open"
    t.datetime "key_timestamp"
  end

  add_index "agendas", ["state"], :name => "index_agendas_on_state"

  create_table "users", :force => true do |t|
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "name"
    t.string   "crypted_password",          :limit => 60
    t.string   "irc_nick"
    t.string   "email"
    t.boolean  "administrator",                           :default => false
    t.boolean  "council_member",                          :default => false,    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",                                   :default => "active"
    t.datetime "key_timestamp"
  end

  add_index "users", ["state"], :name => "index_users_on_state"

end

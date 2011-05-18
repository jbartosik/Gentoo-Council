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

ActiveRecord::Schema.define(:version => 20110601094807) do

  create_table "agenda_items", :force => true do |t|
    t.string   "title"
    t.string   "discussion"
    t.text     "body"
    t.boolean  "rejected",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "agenda_id"
  end

  add_index "agenda_items", ["agenda_id"], :name => "index_agenda_items_on_agenda_id"
  add_index "agenda_items", ["user_id"], :name => "index_agenda_items_on_user_id"

  create_table "agendas", :force => true do |t|
    t.datetime "meeting_time"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state",         :default => "open"
    t.datetime "key_timestamp"
  end

  add_index "agendas", ["state"], :name => "index_agendas_on_state"

  create_table "participations", :force => true do |t|
    t.string   "irc_nick"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "participant_id"
    t.integer  "agenda_id"
  end

  add_index "participations", ["agenda_id"], :name => "index_participations_on_agenda_id"
  add_index "participations", ["participant_id"], :name => "index_participations_on_participant_id"

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

  create_table "votes", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "voting_option_id", :null => false
    t.integer  "user_id",          :null => false
  end

  add_index "votes", ["user_id"], :name => "index_votes_on_user_id"
  add_index "votes", ["voting_option_id", "user_id"], :name => "index_votes_on_voting_option_id_and_user_id", :unique => true
  add_index "votes", ["voting_option_id"], :name => "index_votes_on_voting_option_id"

  create_table "voting_options", :force => true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "agenda_item_id", :null => false
  end

  add_index "voting_options", ["agenda_item_id"], :name => "index_voting_options_on_agenda_item_id"

end

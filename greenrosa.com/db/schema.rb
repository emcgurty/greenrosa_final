ActiveRecord::Schema.define(:version => 0) do

  create_table :sessions do |t|
    t.string :session_id, :null => false
    t.text :data
    t.timestamps
  end

  add_index :sessions, :session_id
  add_index :sessions, :updated_at


  create_table "collaborate", :id => true, :force => true do |t|
    t.string   :user_id,            :limit => 40,  :default => "",    :null => true
    t.string   :alternative_id,            :limit => 40,    :null => false
    t.datetime :created_at
    t.datetime :updated_at
  end

  add_index "collaborate", [:id], :name => "collaborate_id_index"
  add_index "collaborate", [:user_id], :name => "user_id_index"
  add_index "collaborate", [:alternative_id], :name => "alternative_id_index"

  create_table "alternatives", :id => true, :force => true do |t|
    t.string   :application_name,   :limit => 50, :null => false
    t.string   :application_description, :null => false
    t.string   :source_url, :null => true
    t.string   :file_name, :null => true
    t.string   :content_type, :null => true
    t.string   :file_size, :null => true
    t.string   :ruby_version,   :limit => 50, :null => false
    t.string   :rails_version,   :limit => 50, :null => false
    t.string   :application_ide,   :limit => 50, :null => false
    t.integer  :application_status, :null => false
    t.boolean  :approved,                          :default => false
    t.string   :remote_ip,          :limit => 45, :null => false
    t.string   :user_id,            :limit => 40,  :default => "",    :null => true
    t.datetime :created_at
    t.datetime :updated_at
  end

  add_index "alternatives", ["user_id"], :name => "user_id_index"
  add_index "alternatives", ["id"], :name => "alternative_id_index"

  create_table "features", :id => true, :force => true do |t|
    t.string    :alternative_id,     :limit => 40,    :null => false
    t.string    :record_text, :limit => 100
    t.datetime  :created_at
    t.datetime  :updated_at
  end

  add_index "features", ["alternative_id"], :name => "alternative_id_index"
  add_index "features", ["id"], :name => "feature_id_index"
 
  create_table "users", :id => false, :force => true do |t|
    t.string   "user_id",               :limit => 40,      :default => "0",   :null => false
    t.string   "username",                  :limit => 40,           :null => false
    t.string   "email",                     :limit => 100,          :null => false
    t.string   "first_name",                :limit => 24,           :null => false
    t.string   "mi",                        :limit => 1,            :null => true
    t.string   "last_name",                 :limit => 24,           :null => false
    t.string   "user_alias",               :limit => 24,           :null => false
    t.string   "role",                      :limit => 8,   :default => "guest", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remote_ip"
    t.boolean  "approved",                                 :default => false
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.string   "reset_code",                :limit => 40
    t.datetime "activated_at"
    t.integer  "display_name"
  end
  add_index "users", ["user_id"], :name => "uuid_index"
end



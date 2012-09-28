# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120928131730) do

  create_table "app_datas", :force => true do |t|
    t.string   "name"
    t.text     "value"
    t.string   "data_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_datas", ["name"], :name => "by_name", :unique => true

  create_table "articles", :force => true do |t|
    t.string   "article_number"
    t.string   "name"
    t.text     "description"
    t.float    "price"
    t.integer  "subcategory_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.binary   "picture_file"
    t.binary   "picture_thumb_file"
    t.binary   "picture_medium_file"
    t.integer  "picture_width"
    t.integer  "picture_height"
    t.integer  "ord"
    t.float    "width"
    t.float    "height"
    t.float    "depth"
    t.string   "unit",                 :limit => 5
  end

  add_index "articles", ["article_number"], :name => "by_article_number", :unique => true

  create_table "articles_colors", :id => false, :force => true do |t|
    t.integer "article_id"
    t.integer "color_id"
  end

  create_table "blog_posts", :id => false, :force => true do |t|
    t.string   "public_id"
    t.string   "title"
    t.text     "body"
    t.integer  "author_id"
    t.integer  "editor_id"
    t.string   "groups"
    t.boolean  "is_mailed"
    t.boolean  "is_published"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.integer  "ord"
  end

  create_table "colors", :force => true do |t|
    t.string   "label"
    t.string   "hex"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "colors", ["label"], :name => "by_label", :unique => true

  create_table "fair_dates", :force => true do |t|
    t.date     "from_date"
    t.date     "to_date"
    t.string   "name"
    t.string   "homepage"
    t.string   "stand"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "prices", :force => true do |t|
    t.decimal  "amount"
    t.integer  "minimum_count"
    t.integer  "article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "secure_user_requests", :id => false, :force => true do |t|
    t.string   "external_id"
    t.string   "type"
    t.text     "memo"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "secure_user_requests", ["external_id"], :name => "by_external_id", :unique => true

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "password"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.text     "notes"
    t.string   "primary_email_address"
  end

  add_index "users", ["login"], :name => "by_login", :unique => true

end

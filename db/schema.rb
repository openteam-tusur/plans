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

ActiveRecord::Schema.define(:version => 20120530055638) do

  create_table "departments", :force => true do |t|
    t.string   "name"
    t.string   "abbr"
    t.integer  "year_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "departments", ["year_id"], :name => "index_departments_on_year_id"

  create_table "programms", :force => true do |t|
    t.integer  "year_id"
    t.integer  "subdepartment_id"
    t.integer  "speciality_id"
    t.string   "speciality_type"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "programms", ["speciality_id"], :name => "index_programms_on_speciality_id"
  add_index "programms", ["speciality_type"], :name => "index_programms_on_speciality_type"
  add_index "programms", ["subdepartment_id"], :name => "index_programms_on_subdepartment_id"
  add_index "programms", ["year_id"], :name => "index_programms_on_year_id"

  create_table "specialities", :force => true do |t|
    t.string   "code"
    t.string   "name"
    t.string   "type"
    t.integer  "year_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "specialities", ["year_id"], :name => "index_specialities_on_year_id"

  create_table "subdepartments", :force => true do |t|
    t.string   "name"
    t.string   "abbr"
    t.integer  "department_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "subdepartments", ["department_id"], :name => "index_subdepartments_on_department_id"

  create_table "subspecialities", :force => true do |t|
    t.string   "name"
    t.integer  "speciality_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "subspecialities", ["speciality_id"], :name => "index_subspecialities_on_speciality_id"

  create_table "years", :force => true do |t|
    t.integer  "number"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end

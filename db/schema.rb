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

ActiveRecord::Schema.define(:version => 20120803072421) do

  create_table "appendix_items", :force => true do |t|
    t.integer  "appendix_id"
    t.text     "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "appendix_items", ["appendix_id"], :name => "index_appendix_items_on_appendix_id"

  create_table "appendixes", :force => true do |t|
    t.integer  "appendixable_id"
    t.string   "appendixable_type"
    t.string   "title"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "appendixes", ["appendixable_id", "appendixable_type"], :name => "index_appendixes_on_appendixable_id_and_appendixable_type"

  create_table "checks", :force => true do |t|
    t.integer  "semester_id"
    t.integer  "discipline_id"
    t.string   "check_kind"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.datetime "deleted_at"
  end

  add_index "checks", ["discipline_id"], :name => "index_checks_on_discipline_id"
  add_index "checks", ["semester_id"], :name => "index_checks_on_semester_id"

  create_table "departments", :force => true do |t|
    t.string   "title"
    t.string   "abbr"
    t.integer  "number"
    t.integer  "year_id"
    t.datetime "deleted_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "departments", ["year_id"], :name => "index_departments_on_year_id"

  create_table "didactic_units", :force => true do |t|
    t.integer  "gos_id"
    t.string   "discipline"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "didactic_units", ["gos_id"], :name => "index_didactic_units_on_gos_id"

  create_table "disciplines", :force => true do |t|
    t.string   "title"
    t.string   "cycle"
    t.integer  "subspeciality_id"
    t.integer  "subdepartment_id"
    t.datetime "deleted_at"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "summ_loading"
    t.integer  "summ_srs"
    t.string   "code"
    t.string   "cycle_code"
  end

  add_index "disciplines", ["subdepartment_id"], :name => "index_disciplines_on_subdepartment_id"
  add_index "disciplines", ["subspeciality_id"], :name => "index_disciplines_on_subspeciality_id"

  create_table "disciplines_work_programms", :id => false, :force => true do |t|
    t.integer "discipline_id"
    t.integer "work_programm_id"
  end

  add_index "disciplines_work_programms", ["discipline_id"], :name => "index_disciplines_work_programms_on_discipline_id"
  add_index "disciplines_work_programms", ["work_programm_id"], :name => "index_disciplines_work_programms_on_work_programm_id"

  create_table "examination_questions", :force => true do |t|
    t.integer  "work_programm_id"
    t.integer  "semester_id"
    t.string   "question_kind"
    t.integer  "score"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "examination_questions", ["semester_id"], :name => "index_examination_questions_on_semester_id"
  add_index "examination_questions", ["work_programm_id"], :name => "index_examination_questions_on_work_programm_id"

  create_table "exercises", :force => true do |t|
    t.string   "title"
    t.text     "description"
    t.integer  "volume"
    t.integer  "work_programm_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "semester_id"
    t.string   "kind"
    t.integer  "weight"
  end

  add_index "exercises", ["semester_id"], :name => "index_lectures_on_semester_id"
  add_index "exercises", ["work_programm_id"], :name => "index_lectures_on_work_programm_id"

  create_table "goses", :force => true do |t|
    t.text     "title"
    t.string   "code"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.date     "approved_on"
    t.string   "speciality_code"
  end

  add_index "goses", ["speciality_code"], :name => "index_goses_on_speciality_code"

  create_table "loadings", :force => true do |t|
    t.integer  "semester_id"
    t.integer  "discipline_id"
    t.string   "loading_kind"
    t.integer  "value"
    t.datetime "deleted_at"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "loadings", ["discipline_id"], :name => "index_loadings_on_discipline_id"
  add_index "loadings", ["semester_id"], :name => "index_loadings_on_semester_id"

  create_table "missions", :force => true do |t|
    t.text     "description"
    t.integer  "work_programm_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "programms", :force => true do |t|
    t.integer  "with_programm_id"
    t.string   "with_programm_type"
    t.text     "description"
    t.string   "vfs_path"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "programms", ["with_programm_id"], :name => "index_programms_on_with_programm_id"
  add_index "programms", ["with_programm_type"], :name => "index_programms_on_with_programm_type"

  create_table "publications", :force => true do |t|
    t.integer  "work_programm_id"
    t.string   "publication_kind"
    t.text     "text"
    t.text     "url"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "publications", ["work_programm_id"], :name => "index_bibliographic_records_on_work_programm_id"

  create_table "rating_items", :force => true do |t|
    t.integer  "work_programm_id"
    t.integer  "semester_id"
    t.string   "title"
    t.integer  "max_begin_1kt"
    t.integer  "max_1kt_2kt"
    t.integer  "max_2kt_end"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "rating_items", ["semester_id"], :name => "index_rating_items_on_semester_id"
  add_index "rating_items", ["work_programm_id"], :name => "index_rating_items_on_work_programm_id"

  create_table "requirements", :force => true do |t|
    t.integer  "work_programm_id"
    t.string   "requirement_kind"
    t.text     "description"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "self_education_items", :force => true do |t|
    t.integer  "work_programm_id"
    t.integer  "semester_id"
    t.string   "kind"
    t.integer  "hours"
    t.text     "control"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "weight"
  end

  add_index "self_education_items", ["semester_id"], :name => "index_self_education_items_on_semester_id"
  add_index "self_education_items", ["work_programm_id"], :name => "index_self_education_items_on_work_programm_id"

  create_table "semesters", :force => true do |t|
    t.integer  "subspeciality_id"
    t.integer  "number"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.datetime "deleted_at"
  end

  add_index "semesters", ["subspeciality_id"], :name => "index_semesters_on_subspeciality_id"

  create_table "specialities", :force => true do |t|
    t.string   "code"
    t.string   "title"
    t.string   "degree"
    t.integer  "year_id"
    t.datetime "deleted_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "specialities", ["year_id"], :name => "index_specialities_on_year_id"

  create_table "subdepartments", :force => true do |t|
    t.string   "title"
    t.string   "abbr"
    t.integer  "number"
    t.integer  "department_id"
    t.datetime "deleted_at"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "subdepartments", ["department_id"], :name => "index_subdepartments_on_department_id"

  create_table "subspecialities", :force => true do |t|
    t.string   "title"
    t.integer  "speciality_id"
    t.integer  "subdepartment_id"
    t.datetime "deleted_at"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.integer  "graduate_subdepartment_id"
  end

  add_index "subspecialities", ["speciality_id"], :name => "index_subspecialities_on_speciality_id"

  create_table "work_programms", :force => true do |t|
    t.integer  "year"
    t.integer  "discipline_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.text     "purpose"
  end

  add_index "work_programms", ["discipline_id"], :name => "index_work_programms_on_discipline_id"

  create_table "years", :force => true do |t|
    t.integer  "number"
    t.datetime "deleted_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end

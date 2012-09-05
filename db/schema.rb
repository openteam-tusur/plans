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

ActiveRecord::Schema.define(:version => 20120905070954) do

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

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         :default => 0
    t.string   "comment"
    t.string   "remote_address"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], :name => "associated_index"
  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

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

  create_table "contexts", :force => true do |t|
    t.string   "title"
    t.string   "ancestry"
    t.string   "weight"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "contexts", ["ancestry"], :name => "index_contexts_on_ancestry"
  add_index "contexts", ["weight"], :name => "index_contexts_on_weight"

  create_table "departments", :force => true do |t|
    t.string   "title"
    t.string   "abbr"
    t.integer  "number"
    t.integer  "year_id"
    t.datetime "deleted_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "context_id"
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
    t.text     "title"
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
    t.text     "html"
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

  create_table "messages", :force => true do |t|
    t.text     "text"
    t.boolean  "readed"
    t.integer  "work_programm_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "messages", ["work_programm_id"], :name => "index_messages_on_work_programm_id"

  create_table "missions", :force => true do |t|
    t.text     "description"
    t.integer  "work_programm_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "people", :force => true do |t|
    t.text     "academic_degree"
    t.text     "academic_rank"
    t.text     "post"
    t.text     "full_name"
    t.integer  "work_programm_id"
    t.string   "person_kind"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "people", ["work_programm_id"], :name => "index_people_on_work_programm_id"

  create_table "permissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "context_id"
    t.string   "context_type"
    t.string   "role"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "permissions", ["user_id", "role", "context_id", "context_type"], :name => "by_user_and_role_and_context"

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

  create_table "protocols", :force => true do |t|
    t.integer  "work_programm_id"
    t.string   "number"
    t.date     "signed_on"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "protocols", ["work_programm_id"], :name => "index_protocols_on_work_programm_id"

  create_table "publications", :force => true do |t|
    t.integer  "work_programm_id"
    t.string   "publication_kind"
    t.text     "text"
    t.text     "url"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.string   "location"
    t.integer  "count"
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
    t.string   "rating_item_kind"
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
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "gos_generation"
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
    t.integer  "context_id"
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

  create_table "users", :force => true do |t|
    t.string   "uid"
    t.text     "name"
    t.text     "email"
    t.text     "nickname"
    t.text     "first_name"
    t.text     "last_name"
    t.text     "location"
    t.text     "description"
    t.text     "image"
    t.text     "phone"
    t.text     "urls"
    t.text     "raw_info"
    t.integer  "sign_in_count"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "users", ["uid"], :name => "index_users_on_uid"

  create_table "work_programms", :force => true do |t|
    t.integer  "year"
    t.integer  "discipline_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.text     "purpose"
    t.string   "vfs_path"
    t.string   "state"
    t.integer  "creator_id"
  end

  add_index "work_programms", ["discipline_id"], :name => "index_work_programms_on_discipline_id"

  create_table "years", :force => true do |t|
    t.integer  "number"
    t.datetime "deleted_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end

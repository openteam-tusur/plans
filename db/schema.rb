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

ActiveRecord::Schema.define(:version => 20131120044524) do

  create_table "academic_years", :id => false, :force => true do |t|
    t.integer  "id",           :null => false
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "starts_at"
    t.date     "completes_at"
  end

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

  create_table "auditoria", :id => false, :force => true do |t|
    t.integer  "id",          :null => false
    t.string   "number"
    t.integer  "building_id"
    t.integer  "capacity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "room_type"
    t.integer  "pc_count"
    t.text     "description"
  end

  create_table "buildings", :id => false, :force => true do |t|
    t.integer  "id",          :null => false
    t.string   "name"
    t.string   "abbr"
    t.integer  "semester_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chairs", :id => false, :force => true do |t|
    t.integer  "id",          :null => false
    t.string   "name"
    t.string   "abbr"
    t.integer  "faculty_id"
    t.integer  "semester_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "checks", :force => true do |t|
    t.integer  "semester_id"
    t.integer  "discipline_id"
    t.string   "kind"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.datetime "deleted_at"
  end

  add_index "checks", ["discipline_id"], :name => "index_checks_on_discipline_id"
  add_index "checks", ["semester_id"], :name => "index_checks_on_semester_id"

  create_table "competences", :force => true do |t|
    t.text     "content"
    t.string   "index"
    t.integer  "subspeciality_id"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "competences", ["subspeciality_id"], :name => "index_competences_on_subspeciality_id"

  create_table "competences_disciplines", :id => false, :force => true do |t|
    t.integer "competence_id"
    t.integer "discipline_id"
  end

  add_index "competences_disciplines", ["competence_id"], :name => "index_competences_disciplines_on_competence_id"
  add_index "competences_disciplines", ["discipline_id"], :name => "index_competences_disciplines_on_discipline_id"

  create_table "courses", :id => false, :force => true do |t|
    t.integer  "id",         :null => false
    t.integer  "faculty_id"
    t.integer  "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
  end

  create_table "departments", :force => true do |t|
    t.string   "title"
    t.string   "abbr"
    t.integer  "number"
    t.datetime "deleted_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "didactic_units", :force => true do |t|
    t.integer  "gos_id"
    t.string   "discipline"
    t.text     "content"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "didactic_units", ["gos_id"], :name => "index_didactic_units_on_gos_id"

  create_table "discipline_cycles", :id => false, :force => true do |t|
    t.integer  "id",          :null => false
    t.integer  "semester_id"
    t.string   "name"
    t.string   "abbr"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.string   "cycle_id"
    t.string   "kind"
  end

  add_index "disciplines", ["subdepartment_id"], :name => "index_disciplines_on_subdepartment_id"
  add_index "disciplines", ["subspeciality_id"], :name => "index_disciplines_on_subspeciality_id"

  create_table "disciplines_work_programms", :id => false, :force => true do |t|
    t.integer "discipline_id"
    t.integer "work_programm_id"
  end

  add_index "disciplines_work_programms", ["discipline_id"], :name => "index_disciplines_work_programms_on_discipline_id"
  add_index "disciplines_work_programms", ["work_programm_id"], :name => "index_disciplines_work_programms_on_work_programm_id"

  create_table "educations", :id => false, :force => true do |t|
    t.integer  "id",                  :null => false
    t.integer  "group_id"
    t.integer  "discipline_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chair_id"
    t.integer  "discipline_cycle_id"
  end

  create_table "exam_types", :id => false, :force => true do |t|
    t.integer  "id",          :null => false
    t.string   "name"
    t.string   "abbr"
    t.integer  "semester_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "exams", :id => false, :force => true do |t|
    t.integer  "id",           :null => false
    t.integer  "education_id"
    t.integer  "exam_type_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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

  create_table "faculties", :id => false, :force => true do |t|
    t.integer  "id",            :null => false
    t.string   "name"
    t.string   "abbr"
    t.integer  "semester_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "group_pattern"
    t.string   "slug"
    t.boolean  "weekly_view"
  end

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

  create_table "groups", :id => false, :force => true do |t|
    t.integer  "id",            :null => false
    t.string   "number"
    t.integer  "course_id"
    t.integer  "free_count"
    t.integer  "paying_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "plan_verified"
    t.string   "plan_digest"
    t.integer  "position"
    t.string   "slug"
  end

  create_table "lesson_auditoriums", :id => false, :force => true do |t|
    t.integer  "id",            :null => false
    t.integer  "lesson_id"
    t.integer  "auditorium_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lesson_teachers", :id => false, :force => true do |t|
    t.integer "id",         :null => false
    t.integer "lesson_id"
    t.integer "teacher_id"
  end

  create_table "lesson_trainings", :id => false, :force => true do |t|
    t.integer "id",          :null => false
    t.integer "lesson_id"
    t.integer "training_id"
  end

  create_table "lessons", :id => false, :force => true do |t|
    t.integer  "id",                       :null => false
    t.integer  "day"
    t.integer  "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "parity"
    t.string   "note"
    t.string   "name"
    t.text     "cached_groups"
    t.text     "cached_auditoriums"
    t.text     "cached_teachers"
    t.string   "abbr"
    t.string   "kind"
    t.string   "kind_name"
    t.string   "kind_abbr"
    t.integer  "semester_id"
    t.string   "period"
    t.text     "cached_teachers_fullname"
  end

  create_table "lessons_trainings", :id => false, :force => true do |t|
    t.integer "lesson_id"
    t.integer "training_id"
  end

  create_table "lessons_weeks", :id => false, :force => true do |t|
    t.integer "lesson_id"
    t.integer "week_id"
  end

  create_table "loadings", :force => true do |t|
    t.integer  "semester_id"
    t.integer  "discipline_id"
    t.string   "kind"
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
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "work_programm_state"
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

  create_table "periods", :id => false, :force => true do |t|
    t.integer  "id",                   :null => false
    t.integer  "group_id"
    t.integer  "starts_at_week_id"
    t.integer  "completes_at_week_id"
    t.string   "kind"
    t.string   "timetable_state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

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
    t.integer  "subspeciality_id"
    t.text     "description"
    t.string   "vfs_path"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.text     "file_url"
  end

  add_index "programms", ["subspeciality_id"], :name => "index_programms_on_subspeciality_id"

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
    t.string   "kind"
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
    t.string   "kind"
  end

  add_index "rating_items", ["semester_id"], :name => "index_rating_items_on_semester_id"
  add_index "rating_items", ["work_programm_id"], :name => "index_rating_items_on_work_programm_id"

  create_table "requirements", :force => true do |t|
    t.integer  "work_programm_id"
    t.string   "kind"
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
  end

  add_index "subdepartments", ["department_id"], :name => "index_subdepartments_on_department_id"

  create_table "subspecialities", :force => true do |t|
    t.string   "title"
    t.integer  "speciality_id"
    t.integer  "subdepartment_id"
    t.datetime "deleted_at"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "graduated_subdepartment_id"
    t.integer  "department_id"
    t.string   "education_form"
    t.text     "file_path"
    t.string   "plan_digest"
    t.string   "reduced"
    t.string   "group_index"
  end

  add_index "subspecialities", ["graduated_subdepartment_id"], :name => "index_subspecialities_on_graduated_subdepartment_id"
  add_index "subspecialities", ["speciality_id"], :name => "index_subspecialities_on_speciality_id"
  add_index "subspecialities", ["subdepartment_id"], :name => "index_subspecialities_on_subdepartment_id"

  create_table "teacher_trainings", :id => false, :force => true do |t|
    t.integer  "id",          :null => false
    t.integer  "teacher_id"
    t.integer  "training_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teachers", :id => false, :force => true do |t|
    t.integer  "id",          :null => false
    t.string   "lastname"
    t.integer  "semester_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chair_id"
    t.string   "firstname"
    t.string   "middlename"
  end

  create_table "training_types", :id => false, :force => true do |t|
    t.integer  "id",          :null => false
    t.integer  "semester_id"
    t.string   "name"
    t.string   "abbr"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "kind"
  end

  create_table "trainings", :id => false, :force => true do |t|
    t.integer  "id",               :null => false
    t.integer  "education_id"
    t.integer  "training_type_id"
    t.integer  "planned_loading"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "desire"
  end

  create_table "users", :force => true do |t|
    t.string   "uid"
    t.text     "name"
    t.text     "email"
    t.text     "first_name"
    t.text     "last_name"
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

  create_table "weeks", :id => false, :force => true do |t|
    t.integer "id",               :null => false
    t.integer "academic_year_id"
    t.integer "number"
    t.string  "parity"
    t.date    "starts_at"
    t.date    "completes_at"
  end

  create_table "work_plans", :force => true do |t|
    t.integer  "subspeciality_id"
    t.text     "file_file_name"
    t.text     "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.text     "file_url"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  add_index "work_plans", ["subspeciality_id"], :name => "index_work_plans_on_subspeciality_id"

  create_table "work_programms", :force => true do |t|
    t.integer  "year"
    t.integer  "discipline_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.text     "purpose"
    t.string   "vfs_path"
    t.string   "state"
    t.integer  "creator_id"
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.text     "file_url"
  end

  add_index "work_programms", ["discipline_id"], :name => "index_work_programms_on_discipline_id"

  create_table "years", :force => true do |t|
    t.integer  "number"
    t.datetime "deleted_at"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end

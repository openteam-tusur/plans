class DropSelfEducations < ActiveRecord::Migration
  def up
    drop_table :self_educations
  end

  def down
    create_table "self_educations", :force => true do |t|
      t.integer  "work_programm_id"
      t.integer  "lecture_hours"
      t.text     "lecture_control"
      t.datetime "created_at",          :null => false
      t.datetime "updated_at",          :null => false
      t.integer  "lab_hours"
      t.text     "lab_control"
      t.integer  "practice_hours"
      t.text     "practice_control"
      t.integer  "csr_hours"
      t.text     "csr_control"
      t.integer  "exam_hours"
      t.text     "exam_control"
      t.integer  "srs_hours"
      t.text     "srs_control"
      t.integer  "home_work_hours"
      t.text     "home_work_control"
      t.integer  "referat_hours"
      t.text     "referat_control"
      t.integer  "test_hours"
      t.text     "test_control"
      t.integer  "colloquium_hours"
      t.text     "colloquium_control"
      t.integer  "calculation_hours"
      t.text     "calculation_control"
    end

    add_index "self_educations", ["work_programm_id"], :name => "index_self_educations_on_work_programm_id"
  end
end

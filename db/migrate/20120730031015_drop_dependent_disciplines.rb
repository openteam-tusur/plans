class DropDependentDisciplines < ActiveRecord::Migration
  def up
    drop_table :dependent_disciplines
  end

  def down
    create_table "dependent_disciplines", :force => true do |t|
      t.text     "title"
      t.string   "dependency_type"
      t.integer  "work_programm_id"
      t.datetime "created_at",       :null => false
      t.datetime "updated_at",       :null => false
    end
  end
end

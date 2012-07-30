class CreateSelfEducations < ActiveRecord::Migration
  def change
    create_table :self_educations do |t|
      t.references :work_programm
      t.integer :lecture_hours
      t.text :lecture_control

      t.timestamps
    end
    add_index :self_educations, :work_programm_id
  end
end

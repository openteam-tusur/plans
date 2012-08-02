class CreateSelfEducationItems < ActiveRecord::Migration
  def change
    create_table :self_education_items do |t|
      t.references :work_programm
      t.references :semester
      t.string :kind
      t.integer :hours
      t.text :control

      t.timestamps
    end
    add_index :self_education_items, :work_programm_id
    add_index :self_education_items, :semester_id
  end
end

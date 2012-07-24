class CreateDependentDisciplines < ActiveRecord::Migration
  def change
    create_table :dependent_disciplines do |t|
      t.text :title
      t.string :dependency_type
      t.integer :work_programm_id

      t.timestamps
    end
  end
end

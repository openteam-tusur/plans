class CreateDisciplinesWorkProgramms < ActiveRecord::Migration
  def change
    create_table :disciplines_work_programms, :id => false do |t|
      t.references :discipline
      t.references :work_programm
    end
    add_index :disciplines_work_programms, :discipline_id
    add_index :disciplines_work_programms, :work_programm_id
  end
end

class CreateWorkProgramms < ActiveRecord::Migration
  def change
    create_table :work_programms do |t|
      t.integer :year
      t.references :discipline

      t.timestamps
    end
    add_index :work_programms, :discipline_id
  end
end

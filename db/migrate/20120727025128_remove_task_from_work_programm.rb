class RemoveTaskFromWorkProgramm < ActiveRecord::Migration
  def up
    remove_column :work_programms, :taks
  end

  def down
    add_column :work_programms, :taks, :text
  end
end

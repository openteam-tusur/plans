class RemoveTaskFromWorkProgramm < ActiveRecord::Migration
  def up
    remove_column :work_programms, :task
  end

  def down
    add_column :work_programms, :task, :text
  end
end

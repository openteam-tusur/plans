class AddVfsPathToWorkProgramms < ActiveRecord::Migration
  def change
    add_column :work_programms, :vfs_path, :string
  end
end

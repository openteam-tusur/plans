class RenameGraduateSubdepartmentIdToGraduatedSubdepartmentIdInSubspecialities < ActiveRecord::Migration
  def up
    rename_column :subspecialities, :graduate_subdepartment_id, :graduated_subdepartment_id
    add_index :subspecialities, :graduated_subdepartment_id
    add_index :subspecialities, :subdepartment_id
  end
end

class AddGraduateSubdepartmentToSubspeciality < ActiveRecord::Migration
  def change
    add_column :subspecialities, :graduate_subdepartment_id, :integer
  end
end

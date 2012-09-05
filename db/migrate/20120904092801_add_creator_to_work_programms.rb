class AddCreatorToWorkProgramms < ActiveRecord::Migration
  def change
    add_column :work_programms, :creator_id, :integer
  end
end

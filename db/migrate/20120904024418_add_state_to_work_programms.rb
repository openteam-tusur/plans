class AddStateToWorkProgramms < ActiveRecord::Migration
  def change
    add_column :work_programms, :state, :string
  end
end

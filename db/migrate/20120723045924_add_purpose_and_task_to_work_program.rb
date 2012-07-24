class AddPurposeAndTaskToWorkProgram < ActiveRecord::Migration
  def change
    add_column :work_programms, :purpose, :text
    add_column :work_programms, :task, :text
  end
end

class AddWorkProgrammStateToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :work_programm_state, :string
  end
end

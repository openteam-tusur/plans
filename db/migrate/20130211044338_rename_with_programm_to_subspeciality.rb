class RenameWithProgrammToSubspeciality < ActiveRecord::Migration
  def up
    remove_column :programms, :with_programm_type
    rename_column :programms, :with_programm_id, :subspeciality_id
    remove_index :programms, :name => :index_programms_on_with_programm_id
    add_index :programms, :subspeciality_id
  end

  def down
    add_column :programms, :with_programm_type, :string
    rename_column :programms, :subspeciality_id, :with_programm_id
    remove_index :programms, :name => :index_programms_on_subspeciality_id
    add_index :programms, :with_programm_id
    add_index :programms, :with_programm_type
  end
end

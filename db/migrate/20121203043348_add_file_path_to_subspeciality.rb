class AddFilePathToSubspeciality < ActiveRecord::Migration
  def change
    add_column :subspecialities, :file_path, :text
  end
end

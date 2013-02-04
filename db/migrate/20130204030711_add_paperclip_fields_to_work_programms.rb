class AddPaperclipFieldsToWorkProgramms < ActiveRecord::Migration
  def change
    add_column :work_programms, :file_file_name, :string
    add_column :work_programms, :file_content_type, :string
    add_column :work_programms, :file_file_size, :integer
    add_column :work_programms, :file_updated_at, :datetime
    add_column :work_programms, :file_url, :text
  end
end

class AddPaperclipFieldsToProgramms < ActiveRecord::Migration
  def change
    add_column :programms, :file_file_name, :string
    add_column :programms, :file_content_type, :string
    add_column :programms, :file_file_size, :integer
    add_column :programms, :file_updated_at, :datetime
    add_column :programms, :file_url, :text
  end
end

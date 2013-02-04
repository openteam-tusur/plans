class AddPaperclipFieldsToProgramms < ActiveRecord::Migration
  def up
    add_column :programms, :file_file_name, :string
    add_column :programms, :file_content_type, :string
    add_column :programms, :file_file_size, :integer
    add_column :programms, :file_updated_at, :datetime
    add_column :programms, :file_url, :text
    destroy_programms_without_subspeciality
    migrate_programms
  end

  def destroy_programms_without_subspeciality
    Programm.all.delete_if(&:with_programm).map(&:destroy)
  end

  def migrate_programms
    puts "Migrate programms"
    bar = ProgressBar.new(objects.count)

    objects.each do |object|
      Timecop.freeze(object.updated_at) do
        object.file = open(object.vfs_path)
        object.file_file_name = URI.decode File.basename(object.vfs_path)
        object.save!
      end
      bar.increment!
    end
  end

  def objects
    @objects ||= Programm.where("vfs_path IS NOT NULL").where(:file_url => nil)
  end

  def down
    remove_column :programms, :file_file_name
    remove_column :programms, :file_content_type
    remove_column :programms, :file_file_size
    remove_column :programms, :file_updated_at
    remove_column :programms, :file_url
  end
end

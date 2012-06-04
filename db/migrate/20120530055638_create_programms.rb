class CreateProgramms < ActiveRecord::Migration
  def change
    create_table :programms do |t|
      t.references :subspeciality
      t.text        :description
      t.string      :vfs_path
      t.timestamps
    end
    add_index :programms, :subspeciality_id
  end
end

class CreateProgramms < ActiveRecord::Migration
  def change
    create_table :programms do |t|
      t.references  :with_programm, :polymorphic => true
      t.text        :description
      t.string      :vfs_path
      t.timestamps
    end
    add_index :programms, :with_programm_id
    add_index :programms, :with_programm_type
  end
end

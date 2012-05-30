class CreateProgramms < ActiveRecord::Migration
  def change
    create_table :programms do |t|
      t.references :year
      t.references :subdepartment
      t.references :speciality, :polymorphic => true

      t.timestamps
    end
    add_index :programms, :year_id
    add_index :programms, :subdepartment_id
    add_index :programms, :speciality_id
    add_index :programms, :speciality_type
  end
end

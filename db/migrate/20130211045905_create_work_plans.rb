class CreateWorkPlans < ActiveRecord::Migration
  def change
    create_table :work_plans do |t|
      t.references :subspeciality
      t.text :file_file_name
      t.text :file_content_type
      t.integer :file_file_size
      t.datetime :file_updated_at
      t.text :file_url

      t.timestamps
    end
    add_index :work_plans, :subspeciality_id
  end
end

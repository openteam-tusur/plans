class CreateSubspecialities < ActiveRecord::Migration
  def change
    create_table :subspecialities do |t|
      t.string :title
      t.references :speciality
      t.references :subdepartment

      t.datetime :deleted_at
      t.timestamps
    end
    add_index :subspecialities, :speciality_id
  end
end

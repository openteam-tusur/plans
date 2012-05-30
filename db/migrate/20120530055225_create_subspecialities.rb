class CreateSubspecialities < ActiveRecord::Migration
  def change
    create_table :subspecialities do |t|
      t.string :name
      t.references :speciality

      t.timestamps
    end
    add_index :subspecialities, :speciality_id
  end
end

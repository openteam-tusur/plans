class CreateSubdepartments < ActiveRecord::Migration
  def change
    create_table :subdepartments do |t|
      t.string :title
      t.string :abbr
      t.references :department

      t.timestamps
    end
    add_index :subdepartments, :department_id
  end
end

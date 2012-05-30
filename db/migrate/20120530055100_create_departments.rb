class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name
      t.string :abbr
      t.references :year

      t.timestamps
    end
    add_index :departments, :year_id
  end
end

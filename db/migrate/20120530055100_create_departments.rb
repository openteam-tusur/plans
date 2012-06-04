class CreateDepartments < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :title
      t.string :abbr
      t.integer :number
      t.references :year

      t.timestamps
    end
    add_index :departments, :year_id
  end
end

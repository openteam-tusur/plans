class CreateSpecialities < ActiveRecord::Migration
  def change
    create_table :specialities do |t|
      t.string :code
      t.string :name
      t.string :type
      t.references :year

      t.timestamps
    end
    add_index :specialities, :year_id
  end
end

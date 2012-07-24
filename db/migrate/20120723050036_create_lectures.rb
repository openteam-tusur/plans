class CreateLectures < ActiveRecord::Migration
  def change
    create_table :lectures do |t|
      t.string :title
      t.text :description
      t.integer :volume
      t.references :work_programm

      t.timestamps
    end
    add_index :lectures, :work_programm_id
  end
end

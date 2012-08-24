class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.text :academic_degree
      t.text :academic_rank
      t.text :post
      t.text :full_name
      t.references :work_programm
      t.string :person_kind

      t.timestamps
    end
    add_index :people, :work_programm_id
  end
end

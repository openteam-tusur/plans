class CreateSemesters < ActiveRecord::Migration
  def change
    create_table :semesters do |t|
      t.references :subspeciality
      t.integer :number

      t.timestamps
    end
    add_index :semesters, :subspeciality_id
  end
end

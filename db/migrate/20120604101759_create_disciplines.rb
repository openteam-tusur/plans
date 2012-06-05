class CreateDisciplines < ActiveRecord::Migration
  def change
    create_table :disciplines do |t|
      t.string :title
      t.string :cycle
      t.references :subspeciality
      t.references :subdepartment

      t.timestamps
    end
    add_index :disciplines, :subspeciality_id
    add_index :disciplines, :subdepartment_id
  end
end

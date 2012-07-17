class CreateChecks < ActiveRecord::Migration
  def change
    create_table :checks do |t|
      t.references :semester
      t.references :discipline
      t.string :kind

      t.timestamps
    end
    add_index :checks, :semester_id
    add_index :checks, :discipline_id
  end
end

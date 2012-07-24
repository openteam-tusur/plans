class ReplaceSemesterNumberWithSemesterIdForLectures < ActiveRecord::Migration
  def up
    rename_column :lectures, :semester_number, :semester_id
    add_index :lectures, :semester_id
  end

  def down
    remove_index :lectures, :column => :semester_id
    rename_column :lectures, :semester_id, :semester_number
  end
end

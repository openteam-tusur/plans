class RenameLectureToExercise < ActiveRecord::Migration
  def up
    rename_table :lectures, :exercises
    add_column :exercises, :kind, :string
  end

  def down
    remove_column :exercises, :kind
    rename_table :exercises, :lectures
  end
end

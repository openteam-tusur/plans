class ChangeExercisesTitleTypeToText < ActiveRecord::Migration
  def up
    change_column :exercises, :title, :text, :limit => nil
  end

  def down
    change_column :exercises, :title, :string
  end
end

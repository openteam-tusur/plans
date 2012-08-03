class AddWeightToExercises < ActiveRecord::Migration
  def change
    add_column :exercises, :weight, :integer
  end
end

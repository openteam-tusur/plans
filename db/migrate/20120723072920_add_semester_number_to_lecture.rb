class AddSemesterNumberToLecture < ActiveRecord::Migration
  def change
    add_column :lectures, :semester_number, :integer
  end
end

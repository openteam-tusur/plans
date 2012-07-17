class AddDeletedAtToSemester < ActiveRecord::Migration
  def change
    add_column :semesters, :deleted_at, :datetime
  end
end

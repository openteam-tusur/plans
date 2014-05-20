class AddWeeksCountToDiscipline < ActiveRecord::Migration
  def change
    add_column :disciplines, :weeks_count, :integer
  end
end

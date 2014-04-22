class AddSpecialWorkToDiscipline < ActiveRecord::Migration
  def change
    add_column :disciplines, :special_work, :boolean
  end
end

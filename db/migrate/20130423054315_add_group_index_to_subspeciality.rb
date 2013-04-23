class AddGroupIndexToSubspeciality < ActiveRecord::Migration
  def change
    add_column :subspecialities, :group_index, :string
  end
end

class AddReducedToSubspecialities < ActiveRecord::Migration
  def change
    add_column :subspecialities, :reduced, :boolean
    Subspeciality.update_all :reduced => false
  end
end

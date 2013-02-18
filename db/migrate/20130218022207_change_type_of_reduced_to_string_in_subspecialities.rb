class ChangeTypeOfReducedToStringInSubspecialities < ActiveRecord::Migration
  def up
    change_column :subspecialities, :reduced, :string
    Subspeciality.where(:reduced => 'true').update_all(:reduced => 'based_on_secondary_education')
    Subspeciality.where(:reduced => 'false').update_all(:reduced => nil)
  end

  def down
    remove_column :subspecialities, :reduced
    add_column :subspecialities, :reduced, :boolean
  end
end

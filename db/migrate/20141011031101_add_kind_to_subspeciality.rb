class AddKindToSubspeciality < ActiveRecord::Migration
  def up
    add_column :subspecialities, :kind, :string
    Subspeciality.update_all(:kind => 'basic')
  end

  def down
    remove_column :subspecialities, :kind
  end
end

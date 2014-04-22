class AddApprovedOnToSubspeciality < ActiveRecord::Migration
  def change
    add_column :subspecialities, :approved_on, :date
  end
end

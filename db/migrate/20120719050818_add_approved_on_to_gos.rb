class AddApprovedOnToGos < ActiveRecord::Migration
  def change
    add_column :goses, :approved_on, :date
  end
end

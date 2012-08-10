class AddLocationAndCountToPublication < ActiveRecord::Migration
  def change
    add_column :publications, :location, :string
    add_column :publications, :count, :integer
  end
end

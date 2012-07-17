class AddDeletedAtToCheck < ActiveRecord::Migration
  def change
    add_column :checks, :deleted_at, :datetime
  end
end

class AddContextIdToSubdepartments < ActiveRecord::Migration
  def change
    add_column :subdepartments, :context_id, :integer
  end
end

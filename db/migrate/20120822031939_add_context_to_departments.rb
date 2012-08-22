class AddContextToDepartments < ActiveRecord::Migration
  def change
    add_column :departments, :context_id, :integer
  end
end

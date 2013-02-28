class DropContexts < ActiveRecord::Migration
  def up
    drop_table :contexts
    remove_column :departments, :context_id
    remove_column :subdepartments, :context_id
  end

  def down
    create_table "contexts", :force => true do |t|
      t.string   "title"
      t.string   "ancestry"
      t.string   "weight"
      t.timestamps
    end
    add_column :departments, :context_id
    add_column :subdepartments, :context_id
  end
end

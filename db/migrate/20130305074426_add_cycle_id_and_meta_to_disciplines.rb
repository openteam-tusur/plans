class AddCycleIdAndMetaToDisciplines < ActiveRecord::Migration
  def change
    add_column :disciplines, :cycle_id, :string
    add_column :disciplines, :kind, :string
  end
end

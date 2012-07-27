class RenameCycleInDiscipline < ActiveRecord::Migration
  def change
    add_column :disciplines, :cycle_code, :string
    remove_column :disciplines, :component, :string
  end
end

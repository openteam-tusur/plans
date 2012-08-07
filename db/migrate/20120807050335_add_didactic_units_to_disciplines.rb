class AddDidacticUnitsToDisciplines < ActiveRecord::Migration
  def change
    add_column :disciplines, :didactic_units, :text
  end
end

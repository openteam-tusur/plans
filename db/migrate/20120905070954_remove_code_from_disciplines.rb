class RemoveCodeFromDisciplines < ActiveRecord::Migration
  def up
    remove_column :disciplines, :code
  end

  def down
    add_column :disciplines, :code, :string
  end
end

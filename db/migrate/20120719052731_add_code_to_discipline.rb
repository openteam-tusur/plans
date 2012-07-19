class AddCodeToDiscipline < ActiveRecord::Migration
  def change
    add_column :disciplines, :code, :string
  end
end

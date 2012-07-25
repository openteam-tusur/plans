class AddComonentToDiscipline < ActiveRecord::Migration
  def change
    add_column :disciplines, :component, :string
  end
end

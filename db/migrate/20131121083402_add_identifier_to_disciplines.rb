class AddIdentifierToDisciplines < ActiveRecord::Migration
  def change
    add_column :disciplines, :identifier, :string
  end
end

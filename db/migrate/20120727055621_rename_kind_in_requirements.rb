class RenameKindInRequirements < ActiveRecord::Migration
  def change
    rename_column :requirements, :kind, :requirement_kind
  end
end

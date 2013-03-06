class RenameRequirementKindToKindInRequirements < ActiveRecord::Migration
  def change
    rename_column :requirements, :requirement_kind, :kind
  end
end

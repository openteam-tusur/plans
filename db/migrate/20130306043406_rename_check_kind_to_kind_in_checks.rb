class RenameCheckKindToKindInChecks < ActiveRecord::Migration
  def change
    rename_column :checks, :check_kind, :kind
  end
end

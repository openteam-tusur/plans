class RenameKindsInLoadingAndCheck < ActiveRecord::Migration
  def up
    rename_column :loadings, :kind, :loading_kind
    rename_column :checks, :kind, :check_kind
  end

  def down
    rename_column :loadings, :loading_kind, :kind
    rename_column :checks, :check_kind, :kind
  end
end

class RenameLoadingKindToKindInLoadings < ActiveRecord::Migration
  def change
    rename_column :loadings, :loading_kind, :kind
  end
end

class RenameRatingItemKindToKindInRatingItems < ActiveRecord::Migration
  def change
    rename_column :rating_items, :rating_item_kind, :kind
  end
end

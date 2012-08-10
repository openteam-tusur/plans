class AddRatingItemKindToRatingItems < ActiveRecord::Migration
  def change
    add_column :rating_items, :rating_item_kind, :string
  end
end

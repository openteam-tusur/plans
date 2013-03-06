class RenamePublicationKindToKindInPublications < ActiveRecord::Migration
  def change
    rename_column :publications, :publication_kind, :kind
  end
end

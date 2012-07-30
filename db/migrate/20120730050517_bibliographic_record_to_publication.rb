class BibliographicRecordToPublication < ActiveRecord::Migration
  def up
    rename_table :bibliographic_records, :publications
    remove_column :publications, :place
    rename_column :publications, :kind, :publication_kind
  end

  def down
    rename_column :publications, :publication_kind, :kind
    add_column :publications, :place, :string
    rename_table :publications, :bibliographic_records
  end
end

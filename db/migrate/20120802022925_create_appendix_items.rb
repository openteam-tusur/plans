class CreateAppendixItems < ActiveRecord::Migration
  def change
    create_table :appendix_items do |t|
      t.references :appendix
      t.text :description

      t.timestamps
    end
    add_index :appendix_items, :appendix_id
  end
end

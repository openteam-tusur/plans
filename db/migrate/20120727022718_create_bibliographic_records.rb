class CreateBibliographicRecords < ActiveRecord::Migration
  def change
    create_table :bibliographic_records do |t|
      t.references :work_programm
      t.string :kind
      t.string :place
      t.text :text
      t.text :url

      t.timestamps
    end
    add_index :bibliographic_records, :work_programm_id
  end
end

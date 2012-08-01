class CreateAppendixes < ActiveRecord::Migration
  def change
    create_table :appendixes do |t|
      t.references :work_programm
      t.string :kind
      t.text :title

      t.timestamps
    end
    add_index :appendixes, :work_programm_id
  end
end

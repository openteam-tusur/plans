class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :text
      t.boolean :readed
      t.references :work_programm

      t.timestamps
    end
    add_index :messages, :work_programm_id
  end
end

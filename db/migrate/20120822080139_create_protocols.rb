class CreateProtocols < ActiveRecord::Migration
  def change
    create_table :protocols do |t|
      t.references :work_programm
      t.string :number
      t.date :signed_on

      t.timestamps
    end
    add_index :protocols, :work_programm_id
  end
end

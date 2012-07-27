class CreateMissions < ActiveRecord::Migration
  def change
    create_table :missions do |t|
      t.text :description
      t.integer :work_programm_id

      t.timestamps
    end
  end
end

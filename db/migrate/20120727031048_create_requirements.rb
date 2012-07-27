class CreateRequirements < ActiveRecord::Migration
  def change
    create_table :requirements do |t|
      t.integer :work_programm_id
      t.string :kind
      t.text :description

      t.timestamps
    end
  end
end

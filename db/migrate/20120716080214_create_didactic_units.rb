class CreateDidacticUnits < ActiveRecord::Migration
  def change
    create_table :didactic_units do |t|
      t.references :gos
      t.string :discipline
      t.text :content

      t.timestamps
    end
    add_index :didactic_units, :gos_id
  end
end

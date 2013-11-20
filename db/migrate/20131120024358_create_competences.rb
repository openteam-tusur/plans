class CreateCompetences < ActiveRecord::Migration
  def change
    create_table :competences do |t|
      t.text :content
      t.string :index
      t.references :subspeciality

      t.timestamps
    end
    add_index :competences, :subspeciality_id
  end
end

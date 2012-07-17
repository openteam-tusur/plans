class CreateLoadings < ActiveRecord::Migration
  def change
    create_table :loadings do |t|
      t.references :semester
      t.references :discipline
      t.string :kind
      t.integer :value
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :loadings, :semester_id
    add_index :loadings, :discipline_id
  end
end

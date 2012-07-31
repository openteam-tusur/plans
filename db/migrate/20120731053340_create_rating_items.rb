class CreateRatingItems < ActiveRecord::Migration
  def change
    create_table :rating_items do |t|
      t.references :work_programm
      t.references :semester
      t.string :title
      t.integer :max_begin_1kt
      t.integer :max_1kt_2kt
      t.integer :max_2kt_end

      t.timestamps
    end
    add_index :rating_items, :work_programm_id
    add_index :rating_items, :semester_id
  end
end

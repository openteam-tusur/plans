class CreateAppendixes < ActiveRecord::Migration
  def change
    create_table :appendixes do |t|
      t.references :appendixable, :polymorphic => true
      t.string :title

      t.timestamps
    end
    add_index :appendixes, [:appendixable_id, :appendixable_type]
  end
end

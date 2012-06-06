class CreateYears < ActiveRecord::Migration
  def change
    create_table :years do |t|
      t.integer :number

      t.datetime :deleted_at
      t.timestamps
    end
  end
end

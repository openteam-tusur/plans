class CreateYears < ActiveRecord::Migration
  def change
    create_table :years do |t|
      t.integer :number

      t.timestamps
    end
  end
end

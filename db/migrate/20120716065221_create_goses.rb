class CreateGoses < ActiveRecord::Migration
  def change
    create_table :goses do |t|
      t.text :speciality
      t.string :code

      t.timestamps
    end
  end
end

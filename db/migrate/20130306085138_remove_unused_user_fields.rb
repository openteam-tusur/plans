class RemoveUnusedUserFields < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.remove :nickname
      t.remove :location
      t.remove :description
      t.remove :image
      t.remove :phone
      t.remove :urls
    end
  end

  def down
    change_table :users do |t|
      t.text :nickname
      t.text :location
      t.text :description
      t.text :image
      t.text :phone
      t.text :urls
    end
  end
end

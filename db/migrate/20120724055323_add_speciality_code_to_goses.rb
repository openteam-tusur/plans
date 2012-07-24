class AddSpecialityCodeToGoses < ActiveRecord::Migration
  def change
    add_column :goses, :speciality_code, :string
    add_index :goses, :speciality_code
  end
end

class RenameSpecialityToTitleInGoses < ActiveRecord::Migration
  def change
    rename_column :goses, :speciality, :title
  end
end

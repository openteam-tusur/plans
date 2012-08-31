class AddGosGenerationToSpecialities < ActiveRecord::Migration
  def change
    add_column :specialities, :gos_generation, :string
  end
end

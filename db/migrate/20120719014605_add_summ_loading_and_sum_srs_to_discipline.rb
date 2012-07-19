class AddSummLoadingAndSumSrsToDiscipline < ActiveRecord::Migration
  def change
    add_column :disciplines, :summ_loading, :integer
    add_column :disciplines, :summ_srs, :integer
  end
end

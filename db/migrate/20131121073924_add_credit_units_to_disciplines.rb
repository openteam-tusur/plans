class AddCreditUnitsToDisciplines < ActiveRecord::Migration
  def change
    add_column :disciplines, :credit_units, :text
  end
end

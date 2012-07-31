class AddCsrControlToSelfEducations < ActiveRecord::Migration
  def change
    add_column :self_educations, :csr_hours, :integer
    add_column :self_educations, :csr_control, :text
  end
end

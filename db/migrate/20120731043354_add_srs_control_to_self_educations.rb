class AddSrsControlToSelfEducations < ActiveRecord::Migration
  def change
    add_column :self_educations, :srs_hours, :integer
    add_column :self_educations, :srs_control, :text
  end
end
